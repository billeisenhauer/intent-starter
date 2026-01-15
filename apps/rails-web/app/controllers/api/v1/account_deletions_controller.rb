# frozen_string_literal: true

require "ostruct"

module Api
  module V1
    class AccountDeletionsController < BaseController
      before_action :set_household
      before_action :set_member

      def show
        deletion_service = AccountDeletionService.new(user_object)

        render json: {
          member_id: @member.id,
          self_service: deletion_service.self_service?,
          requires_confirmation: deletion_service.requires_confirmation?,
          warnings: deletion_service.warnings,
          immediate: deletion_service.immediate?,
          estimated_completion_days: deletion_service.respond_to?(:estimated_completion) ? deletion_service.estimated_completion : nil
        }
      end

      def create
        confirmed = params[:confirmed] == true || params[:confirmed] == "true"

        unless confirmed
          render json: {
            error: "Account deletion requires explicit confirmation",
            requires_confirmation: true,
            warnings: AccountDeletionService.new(user_object).warnings
          }, status: :unprocessable_entity
          return
        end

        deletion_service = AccountDeletionService.new(user_object)
        result = deletion_service.delete(confirmed: true)

        render json: {
          deleted: true,
          permanent: result.permanent?,
          recoverable: result.recoverable?,
          backup_retention_days: result.backup_retention_days,
          message: "Account and all associated data have been permanently deleted"
        }
      end

      private

      def set_household
        @household = Household.find(params[:household_id])
      end

      def set_member
        @member = @household.members.find(params[:member_id])
      end

      def user_object
        OpenStruct.new(
          id: @member.id,
          email: "#{@member.name.downcase.gsub(' ', '.')}@example.com",
          member_id: @member.id
        )
      end
    end
  end
end
