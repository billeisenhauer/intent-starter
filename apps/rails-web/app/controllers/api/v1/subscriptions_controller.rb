# frozen_string_literal: true

module Api
  module V1
    class SubscriptionsController < BaseController
      before_action :set_household
      before_action :set_subscription, only: %i[show update destroy]

      def index
        subscriptions = @household.subscriptions
        render json: subscriptions.map { |s| subscription_json(s) }
      end

      def show
        render json: subscription_json(@subscription, include_intelligence: true)
      end

      def create
        subscription = @household.subscriptions.create!(subscription_params)
        render json: subscription_json(subscription), status: :created
      end

      def update
        @subscription.update!(subscription_params)
        render json: subscription_json(@subscription)
      end

      def destroy
        @subscription.destroy!
        head :no_content
      end

      def intelligence
        intelligence = SubscriptionIntelligence.for_household(@household)

        render json: {
          household_id: @household.id,
          generated_at: Time.current,
          optimization_target: intelligence.optimization_target,
          success_metrics: intelligence.success_metrics,
          assessments: intelligence.assessments.map { |a| assessment_json(a) },
          recommendations: intelligence.recommendations.map { |r| intelligence_recommendation_json(r) }
        }
      end

      private

      def set_household
        @household = Household.find(params[:household_id])
      end

      def set_subscription
        @subscription = @household.subscriptions.find(params[:id])
      end

      def subscription_params
        params.require(:subscription).permit(:platform, :monthly_cost, :active)
      end

      def subscription_json(subscription, include_intelligence: false)
        json = {
          id: subscription.id,
          household_id: subscription.household_id,
          platform: subscription.platform,
          monthly_cost: subscription.monthly_cost.to_f,
          active: subscription.active,
          last_watched_at: subscription.last_watched_at,
          created_at: subscription.created_at,
          updated_at: subscription.updated_at
        }

        if include_intelligence
          json[:underutilized] = subscription.underutilized?
          json[:days_since_use] = subscription.days_since_use
        end

        json
      end

      def assessment_json(assessment)
        {
          subscription_id: assessment.subscription_id,
          platform: assessment.platform,
          watched_percentage: assessment.watched_percentage,
          flags_low_usage: assessment.flags_low_usage?,
          pros: assessment.pros,
          cons: assessment.cons
        }
      end

      def intelligence_recommendation_json(recommendation)
        {
          action: recommendation.action,
          platform: recommendation.platform,
          value_assessment: recommendation.value_assessment,
          cost: recommendation.cost,
          benefit: recommendation.benefit,
          user_benefit_reason: recommendation.user_benefit_reason
        }
      end
    end
  end
end
