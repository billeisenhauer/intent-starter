# frozen_string_literal: true

# Invariant: Users must be able to delete their account and all associated data.
#
# This evaluation verifies complete and irreversible data deletion capability,
# respecting user autonomy and privacy rights.

require "minitest/autorun"
require "ostruct"

describe "Account Deletion Invariant" do
  before do
    ViewingRecord.delete_all
    AvailabilityObservation.delete_all
    Subscription.delete_all
    Member.delete_all
    Household.delete_all
    Title.delete_all
  end

  describe "deletion availability" do
    it "must provide account deletion functionality" do
      user = create_user_with_member

      deletion_service = AccountDeletionService.new(user)

      assert deletion_service.respond_to?(:delete),
        "Must provide delete method"
    end

    it "must not require contacting support to delete" do
      user = create_user_with_member

      deletion_service = AccountDeletionService.new(user)

      assert deletion_service.self_service?,
        "Account deletion must be self-service"
    end
  end

  describe "deletion completeness" do
    it "must delete all user data" do
      user, member_id = create_user_with_data_and_id

      AccountDeletionService.new(user).delete(confirmed: true)

      assert UserDataAudit.no_data_exists_for?(member_id),
        "All user data must be deleted"
    end

    it "must delete viewing history" do
      user, member_id = create_user_with_data_and_id

      AccountDeletionService.new(user).delete(confirmed: true)

      refute ViewingHistory.exists_for?(member_id),
        "Viewing history must be deleted"
    end

    it "must delete preferences and settings" do
      user, member_id = create_user_with_data_and_id

      AccountDeletionService.new(user).delete(confirmed: true)

      refute UserPreferences.exists_for?(member_id),
        "Preferences must be deleted"
    end
  end

  describe "deletion irreversibility" do
    it "must make deletion permanent" do
      user, _member_id = create_user_with_data_and_id

      result = AccountDeletionService.new(user).delete(confirmed: true)

      assert result.permanent?,
        "Deletion must be permanent"
      refute result.recoverable?,
        "Deletion must not be recoverable"
    end

    it "must not retain data in backups beyond retention period" do
      user, _member_id = create_user_with_data_and_id

      result = AccountDeletionService.new(user).delete(confirmed: true)

      assert result.respond_to?(:backup_retention_days),
        "Must document backup retention period"
      assert result.backup_retention_days <= 30,
        "Backup retention should be reasonable (<=30 days)"
    end
  end

  describe "deletion confirmation" do
    it "must require explicit confirmation" do
      user = create_user_with_member

      deletion_service = AccountDeletionService.new(user)

      assert deletion_service.requires_confirmation?,
        "Deletion must require explicit confirmation"
    end

    it "must warn user about permanence" do
      user = create_user_with_member

      deletion_service = AccountDeletionService.new(user)
      warnings = deletion_service.warnings

      assert warnings.any? { |w| w.include?("permanent") || w.include?("cannot be undone") },
        "Must warn user about permanent deletion"
    end
  end

  describe "deletion timing" do
    it "must complete within reasonable timeframe" do
      user = create_user_with_member

      deletion_service = AccountDeletionService.new(user)

      assert deletion_service.respond_to?(:estimated_completion) ||
             deletion_service.immediate?,
        "Must provide completion timeline or be immediate"

      if deletion_service.respond_to?(:estimated_completion)
        assert deletion_service.estimated_completion <= 30,
          "Deletion should complete within 30 days"
      end
    end
  end

  def create_user_with_member
    household = Household.create!(name: "Test Household")
    member = household.add_member(name: "Test User")

    OpenStruct.new(
      id: member.id,
      email: "test@example.com",
      member_id: member.id
    )
  end

  def create_user_with_data_and_id
    household = Household.create!(name: "Test Household")
    member = household.add_member(name: "Test User")
    member_id = member.id

    # Add viewing history
    title = Title.create!(external_id: "test_#{SecureRandom.hex(4)}", name: "Test Title", title_type: "movie")
    member.mark_watched(title, fully_watched: true)

    user = OpenStruct.new(
      id: member_id,
      email: "test@example.com",
      member_id: member_id
    )

    [user, member_id]
  end
end
