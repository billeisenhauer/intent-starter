# frozen_string_literal: true

module Api
  module V1
    class BaseController < ApplicationController
      rescue_from ActiveRecord::RecordNotFound, with: :not_found
      rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
      rescue_from ActionController::ParameterMissing, with: :bad_request
      rescue_from Household::MembershipError, with: :forbidden

      private

      def not_found(exception)
        render json: { error: exception.message }, status: :not_found
      end

      def unprocessable_entity(exception)
        render json: { error: exception.message, details: exception.record&.errors&.full_messages }, status: :unprocessable_entity
      end

      def bad_request(exception)
        render json: { error: exception.message }, status: :bad_request
      end

      def forbidden(exception)
        render json: { error: exception.message }, status: :forbidden
      end

      def current_household
        @current_household ||= Household.find(params[:household_id])
      end

      def current_member
        @current_member ||= current_household.members.find(params[:member_id])
      end
    end
  end
end
