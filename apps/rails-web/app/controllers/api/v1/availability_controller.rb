# frozen_string_literal: true

module Api
  module V1
    class AvailabilityController < BaseController
      before_action :set_title, only: %i[show report]

      def show
        availability = AvailabilityService.for_title(@title)

        render json: {
          title_id: @title.id,
          title_name: @title.name,
          platforms: availability.map do |platform, info|
            {
              platform: platform,
              confidence: info[:confidence],
              observation_count: info[:observation_count],
              last_confirmed: info[:last_confirmed]
            }
          end
        }
      end

      def report
        # Find or require observer (member) from params
        observer = Member.find(observation_params[:observer_id])

        observation = AvailabilityObservation.create!(
          title: @title,
          platform: observation_params[:platform],
          observer: observer,
          confidence: observation_params[:confidence] || 0.8,
          observed_at: Time.current
        )

        render json: {
          id: observation.id,
          title_id: observation.title_id,
          platform: observation.platform,
          observer_id: observation.observer_id,
          confidence: observation.confidence.to_f,
          observed_at: observation.observed_at,
          source: observation.source
        }, status: :created
      end

      private

      def set_title
        @title = Title.find(params[:title_id] || params[:id])
      end

      def observation_params
        params.require(:observation).permit(:platform, :observer_id, :confidence)
      end
    end
  end
end
