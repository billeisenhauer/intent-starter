# frozen_string_literal: true

module Api
  module V1
    class MembersController < BaseController
      before_action :set_household
      before_action :set_member, only: %i[show update destroy]

      def index
        render json: @household.members.map { |m| member_json(m) }
      end

      def show
        render json: member_json(@member, include_stats: true)
      end

      def create
        member = @household.add_member(**member_params.to_h.symbolize_keys)
        render json: member_json(member), status: :created
      end

      def update
        @member.update!(member_params)
        render json: member_json(@member)
      end

      def destroy
        @household.remove_member(@member)
        head :no_content
      end

      private

      def set_household
        @household = Household.find(params[:household_id])
      end

      def set_member
        @member = @household.members.find(params[:id])
      end

      def member_params
        params.require(:member).permit(:name)
      end

      def member_json(member, include_stats: false)
        json = {
          id: member.id,
          household_id: member.household_id,
          name: member.name,
          created_at: member.created_at,
          updated_at: member.updated_at
        }

        if include_stats
          json[:stats] = {
            titles_watched: member.fully_watched_titles.count,
            titles_in_progress: member.in_progress_titles.count
          }
        end

        json
      end
    end
  end
end
