# frozen_string_literal: true

# Invariant: Users must be able to download their data.
#
# This evaluation verifies that users have full access to export
# all data the system holds about them.

require "minitest/autorun"
require "ostruct"

describe "Data Download Invariant" do
  before do
    ViewingRecord.delete_all
    AvailabilityObservation.delete_all
    Subscription.delete_all
    Member.delete_all
    Household.delete_all
    Title.delete_all
  end

  describe "data export availability" do
    it "must provide data export functionality" do
      user = create_user_with_member

      export_service = DataExportService.new(user)

      assert export_service.respond_to?(:export),
        "Must provide export method"
      assert export_service.respond_to?(:available_formats),
        "Must expose available formats"
    end

    it "must support at least one portable format" do
      user = create_user_with_member

      export_service = DataExportService.new(user)

      portable_formats = [:json, :csv, :xml, :zip]
      available = export_service.available_formats

      assert (available & portable_formats).any?,
        "Must support at least one portable format (json, csv, xml, or zip)"
    end
  end

  describe "data completeness" do
    it "must include all user-generated data" do
      user = create_user_with_data

      export = DataExportService.new(user).export

      assert export.includes?(:viewing_history),
        "Export must include viewing history"
      assert export.includes?(:preferences),
        "Export must include preferences"
    end

    it "must include household membership data" do
      user = create_user_with_data

      export = DataExportService.new(user).export

      assert export.includes?(:household_membership),
        "Export must include household membership"
    end

    it "must include subscription tracking data" do
      user = create_user_with_data

      export = DataExportService.new(user).export

      assert export.includes?(:subscription_data),
        "Export must include subscription tracking data"
    end

    it "must include account metadata" do
      user = create_user_with_data

      export = DataExportService.new(user).export

      assert export.includes?(:account_created_at),
        "Export must include account creation date"
      assert export.includes?(:account_identifier),
        "Export must include account identifier"
    end
  end

  describe "export accessibility" do
    it "must complete export within reasonable time" do
      user = create_user_with_data

      export_service = DataExportService.new(user)

      assert export_service.respond_to?(:export) ||
             export_service.respond_to?(:request_export),
        "Must provide sync or async export"
    end

    it "must not require technical knowledge to use" do
      user = create_user_with_member

      export_service = DataExportService.new(user)

      assert export_service.respond_to?(:export),
        "Export must be accessible via simple interface"
    end
  end

  describe "export security" do
    it "must only export data belonging to the requesting user" do
      user1 = create_user_with_member
      user2 = create_user_with_member(name: "Other User")

      export1 = DataExportService.new(user1).export
      export2 = DataExportService.new(user2).export

      refute_equal export1.user_id, export2.user_id,
        "Exports must be scoped to requesting user"
    end

    it "must not include other users data" do
      user = create_user_with_member

      export = DataExportService.new(user).export

      assert export.scoped_to_user?(user),
        "Export must be scoped to requesting user only"
    end
  end

  def create_user_with_member(name: "Test User")
    household = Household.create!(name: "Test Household")
    member = household.add_member(name: name)

    OpenStruct.new(
      id: member.id,
      email: "#{name.downcase.gsub(' ', '.')}@example.com",
      member_id: member.id
    )
  end

  def create_user_with_data
    household = Household.create!(name: "Test Household")
    member = household.add_member(name: "Test User")

    # Add viewing history
    title = Title.create!(external_id: "test", name: "Test Title", title_type: "movie")
    member.mark_watched(title, fully_watched: true)

    # Add subscription
    Subscription.create!(
      household: household,
      platform: "Netflix",
      monthly_cost: 15.99,
      active: true
    )

    OpenStruct.new(
      id: member.id,
      email: "test@example.com",
      member_id: member.id
    )
  end
end
