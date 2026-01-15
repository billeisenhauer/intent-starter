# frozen_string_literal: true

module Api
  module V1
    class ViewingRecordsController < BaseController
      before_action :set_household
      before_action :set_member
      before_action :set_title, only: %i[create update]

      def index
        records = @member.viewing_records.includes(:title)
        render json: records.map { |r| viewing_record_json(r) }
      end

      def create
        @member.mark_watched(@title, **watch_params)
        record = @member.viewing_records.find_by!(title: @title)
        render json: viewing_record_json(record), status: :created
      end

      def update
        @member.mark_watched(@title, **watch_params)
        record = @member.viewing_records.find_by!(title: @title)
        render json: viewing_record_json(record)
      end

      def destroy
        record = @member.viewing_records.find(params[:id])
        record.destroy!
        head :no_content
      end

      private

      def set_household
        @household = Household.find(params[:household_id])
      end

      def set_member
        @member = @household.members.find(params[:member_id])
      end

      def set_title
        @title = Title.find(params[:title_id] || params.dig(:viewing_record, :title_id))
      end

      def watch_params
        permitted = params.require(:viewing_record).permit(:fully_watched, :progress_percentage)
        {
          fully_watched: permitted[:fully_watched] == true || permitted[:fully_watched] == "true",
          progress_percentage: permitted[:progress_percentage]&.to_i
        }.compact
      end

      def viewing_record_json(record)
        {
          id: record.id,
          member_id: record.member_id,
          title: {
            id: record.title.id,
            external_id: record.title.external_id,
            name: record.title.name,
            title_type: record.title.title_type
          },
          fully_watched: record.fully_watched,
          progress_percentage: record.progress_percentage,
          last_watched_at: record.last_watched_at,
          created_at: record.created_at
        }
      end
    end
  end
end
