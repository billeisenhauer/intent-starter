# frozen_string_literal: true

module Api
  module V1
    class HouseholdsController < BaseController
      before_action :set_household, only: %i[show update destroy]

      def index
        households = Household.all
        render json: households.map { |h| household_json(h) }
      end

      def show
        render json: household_json(@household, include_members: true)
      end

      def create
        household = Household.create!(household_params)
        render json: household_json(household), status: :created
      end

      def update
        @household.update!(household_params)
        render json: household_json(@household)
      end

      def destroy
        @household.destroy!
        head :no_content
      end

      private

      def set_household
        @household = Household.find(params[:id])
      end

      def household_params
        params.require(:household).permit(:name)
      end

      def household_json(household, include_members: false)
        json = {
          id: household.id,
          name: household.name,
          member_count: household.members.count,
          created_at: household.created_at,
          updated_at: household.updated_at
        }

        if include_members
          json[:members] = household.members.map do |member|
            {
              id: member.id,
              name: member.name,
              created_at: member.created_at
            }
          end
        end

        json
      end
    end
  end
end
