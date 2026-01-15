# frozen_string_literal: true

module Api
  module V1
    class TitlesController < BaseController
      before_action :set_title, only: %i[show update]

      def index
        titles = Title.all
        titles = titles.where(title_type: params[:type]) if params[:type].present?
        titles = titles.where("name ILIKE ?", "%#{params[:q]}%") if params[:q].present?
        titles = titles.limit(params[:limit] || 50)

        render json: titles.map { |t| title_json(t) }
      end

      def show
        render json: title_json(@title, include_availability: true)
      end

      def create
        title = Title.create!(title_params)
        render json: title_json(title), status: :created
      end

      def update
        @title.update!(title_params)
        render json: title_json(@title)
      end

      private

      def set_title
        @title = Title.find(params[:id])
      end

      def title_params
        params.require(:title).permit(:external_id, :name, :title_type)
      end

      def title_json(title, include_availability: false)
        json = {
          id: title.id,
          external_id: title.external_id,
          name: title.name,
          title_type: title.title_type,
          created_at: title.created_at,
          updated_at: title.updated_at
        }

        if include_availability
          availability = AvailabilityService.for_title(title)
          json[:availability] = availability.map do |platform, info|
            {
              platform: platform,
              confidence: info[:confidence],
              last_confirmed: info[:last_confirmed]
            }
          end
        end

        json
      end
    end
  end
end
