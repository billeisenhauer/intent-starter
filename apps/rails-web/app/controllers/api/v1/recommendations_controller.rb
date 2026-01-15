# frozen_string_literal: true

module Api
  module V1
    class RecommendationsController < BaseController
      before_action :set_household

      def index
        recommendations = RecommendationEngine.for_household(@household)

        render json: {
          household_id: @household.id,
          generated_at: Time.current,
          count: recommendations.count,
          recommendations: recommendations.map { |r| recommendation_json(r) }
        }
      end

      private

      def set_household
        @household = Household.find(params[:household_id])
      end

      def recommendation_json(recommendation)
        {
          title: {
            id: recommendation.title.id,
            external_id: recommendation.title.external_id,
            name: recommendation.title.name,
            title_type: recommendation.title.title_type
          },
          confidence: {
            level: recommendation.confidence.to_label,
            score: recommendation.confidence.value,
            rank: recommendation.confidence.confidence_rank
          },
          reasons: recommendation.reasons.map do |reason|
            {
              explanation: reason.text
            }
          end,
          availability: availability_for(recommendation.title)
        }
      end

      def availability_for(title)
        availability = AvailabilityService.for_title(title)
        return [] if availability.platforms.empty?

        availability.platforms.map do |platform|
          {
            platform: platform,
            confidence: availability.confidence_for(platform),
            last_confirmed: availability.last_verified_at
          }
        end
      end
    end
  end
end
