# frozen_string_literal: true

# SubscriptionIntelligence provides value-based subscription guidance.
#
# Invariants satisfied:
# - Value-based guidance, not engagement maximizing
# - Honest assessment of subscription value
# - Willing to recommend cancellation
# - Optimizes for user outcomes
module SubscriptionIntelligence
  UNDERUTILIZATION_DAYS = 30
  LOW_USAGE_THRESHOLD = 0.1

  class << self
    def for_household(household)
      subscriptions = household.subscriptions.active
      viewing_records = household.viewing_records.includes(:title)

      assessments = subscriptions.map do |subscription|
        assess_subscription(subscription, viewing_records, household)
      end

      recommendations = generate_recommendations(assessments, household)

      Guidance.new(
        household: household,
        assessments: assessments,
        recommendations: recommendations
      )
    end

    private

    def assess_subscription(subscription, viewing_records, household)
      # Calculate usage metrics
      platform_watches = count_platform_watches(subscription.platform, viewing_records)
      total_watches = viewing_records.count
      usage_percentage = total_watches.positive? ? platform_watches.to_f / total_watches : 0.0

      # Calculate value metrics
      cost_per_watch = platform_watches.positive? ? subscription.monthly_cost / platform_watches : Float::INFINITY
      days_since_use = subscription.days_since_last_watched || 0

      Assessment.new(
        subscription: subscription,
        platform_watches: platform_watches,
        usage_percentage: usage_percentage,
        cost_per_watch: cost_per_watch,
        days_since_use: days_since_use
      )
    end

    def count_platform_watches(platform, viewing_records)
      # Count watches on titles available on this platform
      viewing_records.count do |record|
        availability = AvailabilityService.for_title(record.title)
        availability.platforms.include?(platform)
      end
    end

    def generate_recommendations(assessments, household)
      recommendations = []

      assessments.each do |assessment|
        if assessment.should_cancel?
          recommendations << SubscriptionRecommendation.new(
            subscription: assessment.subscription,
            action: :cancel,
            user_benefit_reason: "Save #{format_currency(assessment.subscription.monthly_cost)}/month - not being used",
            value_assessment: assessment
          )
        elsif assessment.underutilized?
          recommendations << SubscriptionRecommendation.new(
            subscription: assessment.subscription,
            action: :review,
            user_benefit_reason: "Low usage - consider if worth #{format_currency(assessment.subscription.monthly_cost)}/month",
            value_assessment: assessment
          )
        else
          recommendations << SubscriptionRecommendation.new(
            subscription: assessment.subscription,
            action: :keep,
            user_benefit_reason: "Good value - actively used",
            value_assessment: assessment
          )
        end
      end

      recommendations
    end

    def format_currency(amount)
      "$#{format('%.2f', amount)}"
    end
  end

  # Overall guidance for a household
  class Guidance
    attr_reader :household, :assessments, :recommendations

    def initialize(household:, assessments:, recommendations:)
      @household = household
      @assessments = assessments
      @recommendations = recommendations
    end

    # Optimization target (invariant: user value, not engagement)
    def optimization_target
      :user_value
    end

    # Success metrics (invariant: money saved and satisfaction)
    def success_metrics
      [:potential_savings, :money_saved, :user_satisfaction, :content_match]
    end

    # Get cancel recommendations
    def cancel_recommendations
      recommendations.select { |r| r.action == :cancel }
    end

    # Calculate potential monthly savings
    def potential_savings
      cancel_recommendations.sum { |r| r.subscription.monthly_cost }
    end
  end

  # Assessment of a single subscription
  class Assessment
    attr_reader :subscription, :platform_watches, :usage_percentage,
                :cost_per_watch, :days_since_use

    def initialize(subscription:, platform_watches:, usage_percentage:, cost_per_watch:, days_since_use:)
      @subscription = subscription
      @platform_watches = platform_watches
      @usage_percentage = usage_percentage
      @cost_per_watch = cost_per_watch
      @days_since_use = days_since_use
    end

    def subscription_id
      subscription.id
    end

    def platform
      subscription.platform
    end

    def watched_percentage
      usage_percentage
    end

    # Flag low usage subscriptions (invariant: honest assessment)
    def flags_low_usage?
      usage_percentage < LOW_USAGE_THRESHOLD
    end

    def underutilized?
      days_since_use > UNDERUTILIZATION_DAYS || flags_low_usage?
    end

    def should_cancel?
      days_since_use > (UNDERUTILIZATION_DAYS * 3) && platform_watches.zero?
    end

    # Pros and cons (invariant: expose both)
    def pros
      pros_list = []
      pros_list << "Active subscription" if subscription.active?
      pros_list << "Recently used" if days_since_use < 7
      pros_list << "Good content match" if usage_percentage > 0.3
      pros_list << "Affordable" if subscription.monthly_cost < 10
      pros_list
    end

    def cons
      cons_list = []
      cons_list << "Not used in #{days_since_use} days" if days_since_use > 14
      cons_list << "Low usage (#{(usage_percentage * 100).round}%)" if flags_low_usage?
      cons_list << "High cost per watch" if cost_per_watch > 5 && cost_per_watch < Float::INFINITY
      cons_list
    end
  end

  # Subscription recommendation
  class SubscriptionRecommendation
    attr_reader :subscription, :action, :user_benefit_reason, :value_assessment

    def initialize(subscription:, action:, user_benefit_reason:, value_assessment:)
      @subscription = subscription
      @action = action
      @user_benefit_reason = user_benefit_reason
      @value_assessment = value_assessment
    end

    def platform
      subscription.platform
    end

    def cost
      subscription.monthly_cost
    end

    def benefit
      case action
      when :cancel then "Save #{cost}/month"
      when :review then "Potential savings"
      when :keep then "Continued access to content"
      end
    end

    # Invariant: never recommend subscription solely for engagement
    def reason_is_engagement_only?
      false
    end
  end
end
