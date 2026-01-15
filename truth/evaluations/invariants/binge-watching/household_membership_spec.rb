# frozen_string_literal: true

# Invariant: Household members must be first-class entities, not individual-only accounts.
#
# This evaluation verifies that the system treats households as the primary unit,
# with members as distinct participants who share viewing context.

require "minitest/autorun"

describe "Household Membership Invariant" do
  before do
    ViewingRecord.delete_all
    AvailabilityObservation.delete_all
    Subscription.delete_all
    Member.delete_all
    Household.delete_all
    Title.delete_all
  end

  describe "household structure" do
    it "must support multiple members per household" do
      household = Household.create!(name: "Test Household")

      member1 = household.add_member(name: "Alice")
      member2 = household.add_member(name: "Bob")

      assert_equal 2, household.members.count
      assert household.members.include?(member1)
      assert household.members.include?(member2)
    end

    it "must require at least one member" do
      household = Household.create!(name: "Test Household")
      member = household.add_member(name: "Only Member")

      assert_raises(Household::MembershipError) do
        household.remove_member(member)
      end
    end

    it "must track viewing history per member" do
      household = Household.create!(name: "Test Household")
      member1 = household.add_member(name: "Alice")
      member2 = household.add_member(name: "Bob")

      title = Title.create!(external_id: "test", name: "Test Title", title_type: "movie")
      member1.mark_watched(title)

      assert member1.watched?(title)
      refute member2.watched?(title)
      assert household.watched_by_any?(title)
    end
  end

  describe "member identity" do
    it "must give each member a unique identifier" do
      household = Household.create!(name: "Test Household")
      member1 = household.add_member(name: "Alice")
      member2 = household.add_member(name: "Bob")

      refute_nil member1.id
      refute_nil member2.id
      refute_equal member1.id, member2.id
    end

    it "must allow members to have display names" do
      household = Household.create!(name: "Test Household")
      member = household.add_member(name: "Alice")

      assert_equal "Alice", member.name
    end
  end

  describe "household-level aggregation" do
    it "must aggregate viewing history across all members" do
      household = Household.create!(name: "Test Household")
      member1 = household.add_member(name: "Alice")
      member2 = household.add_member(name: "Bob")

      title1 = Title.create!(external_id: "t1", name: "Title 1", title_type: "movie")
      title2 = Title.create!(external_id: "t2", name: "Title 2", title_type: "movie")

      member1.mark_watched(title1)
      member2.mark_watched(title2)

      assert_equal 2, household.all_watched_titles.count
      assert household.all_watched_titles.map(&:id).include?(title1.id)
      assert household.all_watched_titles.map(&:id).include?(title2.id)
    end

    it "must deduplicate titles watched by multiple members" do
      household = Household.create!(name: "Test Household")
      member1 = household.add_member(name: "Alice")
      member2 = household.add_member(name: "Bob")

      shared_title = Title.create!(external_id: "shared", name: "Shared", title_type: "movie")

      member1.mark_watched(shared_title)
      member2.mark_watched(shared_title)

      matching = household.all_watched_titles.select { |t| t.id == shared_title.id }
      assert_equal 1, matching.count
    end
  end
end
