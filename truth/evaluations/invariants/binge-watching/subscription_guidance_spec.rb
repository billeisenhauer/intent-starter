# frozen_string_literal: true

# Invariant: Subscription intelligence must provide value-based guidance,
# not maximize engagement.
#
# This evaluation verifies that subscription recommendations serve user
# interests (saving money, accessing wanted content) not platform interests.

require "minitest/autorun"

describe "Subscription Guidance Invariant" do
  before do
    ViewingRecord.delete_all
    AvailabilityObservation.delete_all
    Subscription.delete_all
    Member.delete_all
    Household.delete_all
    Title.delete_all
  end

  describe "value-based recommendations" do
    it "must include cost-benefit analysis" do
      household = create_household_with_subscriptions

      guidance = SubscriptionIntelligence.for_household(household)

      guidance.recommendations.each do |rec|
        assert rec.respond_to?(:value_assessment),
          "Recommendation must include value assessment"
        assert rec.respond_to?(:cost),
          "Recommendation must include cost information"
        assert rec.respond_to?(:benefit),
          "Recommendation must include benefit information"
      end
    end

    it "must recommend cancellation when appropriate" do
      household = create_household_with_unused_subscription

      guidance = SubscriptionIntelligence.for_household(household)

      assert guidance.respond_to?(:cancel_recommendations),
        "Must support cancel recommendations"
    end

    it "must not recommend subscriptions solely to increase engagement" do
      household = create_household_with_subscriptions

      guidance = SubscriptionIntelligence.for_household(household)

      guidance.recommendations.each do |rec|
        if rec.action == :subscribe
          assert rec.user_benefit_reason.present?,
            "Subscribe recommendation must have user benefit reason"
          refute rec.reason_is_engagement_only?,
            "Must not recommend subscription solely for engagement"
        end
      end
    end
  end

  describe "honest assessment" do
    it "must acknowledge when subscription has limited value" do
      household = create_household_with_subscriptions

      guidance = SubscriptionIntelligence.for_household(household)

      guidance.assessments.each do |assessment|
        if assessment.watched_percentage < 0.1
          assert assessment.flags_low_usage?,
            "Must flag subscriptions with <10% usage"
        end
      end
    end

    it "must not hide negative information about subscriptions" do
      household = create_household_with_subscriptions

      guidance = SubscriptionIntelligence.for_household(household)

      guidance.assessments.each do |assessment|
        assert assessment.respond_to?(:pros),
          "Assessment must expose pros"
        assert assessment.respond_to?(:cons),
          "Assessment must expose cons"
      end
    end
  end

  describe "user-centric metrics" do
    it "must optimize for user outcomes not platform outcomes" do
      household = create_household_with_subscriptions

      guidance = SubscriptionIntelligence.for_household(household)

      assert guidance.respond_to?(:optimization_target),
        "Must expose optimization target"
      assert_equal :user_value, guidance.optimization_target,
        "Must optimize for user value, not platform metrics"
    end

    it "must measure success by money saved and satisfaction" do
      household = create_household_with_subscriptions

      guidance = SubscriptionIntelligence.for_household(household)
      metrics = guidance.success_metrics

      assert metrics.include?(:potential_savings) || metrics.include?(:money_saved),
        "Must track money saved"
      assert metrics.include?(:user_satisfaction) || metrics.include?(:content_match),
        "Must track satisfaction or content match"
    end
  end

  def create_household_with_subscriptions
    household = Household.create!(name: "Test Household")
    household.add_member(name: "Test Member")

    Subscription.create!(
      household: household,
      platform: "Netflix",
      monthly_cost: 15.99,
      active: true,
      last_watched_at: 5.days.ago
    )

    Subscription.create!(
      household: household,
      platform: "Hulu",
      monthly_cost: 12.99,
      active: true,
      last_watched_at: 10.days.ago
    )

    household
  end

  def create_household_with_unused_subscription
    household = Household.create!(name: "Test Household")
    household.add_member(name: "Test Member")

    Subscription.create!(
      household: household,
      platform: "UnusedService",
      monthly_cost: 9.99,
      active: true,
      last_watched_at: 90.days.ago
    )

    household
  end
end
