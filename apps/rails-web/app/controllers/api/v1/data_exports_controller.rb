# frozen_string_literal: true

require "ostruct"

module Api
  module V1
    class DataExportsController < BaseController
      before_action :set_household
      before_action :set_member

      def show
        export_service = DataExportService.new(user_object)

        render json: {
          member_id: @member.id,
          available_formats: export_service.available_formats,
          export_url: "/api/v1/households/#{@household.id}/members/#{@member.id}/data_export"
        }
      end

      def create
        format = params[:format]&.to_sym || :json
        export_service = DataExportService.new(user_object)
        export = export_service.export(format: format)

        case format
        when :json
          render json: export.data
        when :csv
          send_data export.data, filename: "export_#{@member.id}.csv", type: "text/csv"
        when :zip
          send_data export.data, filename: "export_#{@member.id}.zip", type: "application/zip"
        else
          render json: export.data
        end
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
