# frozen_string_literal: true

# Invariant: System must not re-recommend titles fully watched by the household.
#
# This evaluation verifies that the recommendation engine respects viewing
# history and never suggests content the household has already completed.

require "minitest/autorun"

describe "Finished Title Exclusion Invariant" do
  before do
    ViewingRecord.delete_all
    AvailabilityObservation.delete_all
    Subscription.delete_all
    Member.delete_all
    Household.delete_all
    Title.delete_all
  end

  describe "when household has fully watched titles" do
    it "must not recommend any fully watched title" do
      household = Household.create!(name: "Test Household")
      member = household.add_member(name: "Test Member")

      # Create and watch some titles
      watched_titles = 5.times.map do |i|
        title = Title.create!(external_id: "watched_#{i}", name: "Watched #{i}", title_type: "movie")
        member.mark_watched(title, fully_watched: true)
        title
      end

      # Create unwatched titles
      5.times { |i| Title.create!(external_id: "unwatched_#{i}", name: "Unwatched #{i}", title_type: "movie") }

      recommendations = RecommendationEngine.for_household(household)
      watched_ids = watched_titles.map(&:id)

      recommendations.each do |rec|
        refute watched_ids.include?(rec.title_id),
          "Recommendation must not include fully watched title #{rec.title_id}"
      end
    end

    it "must exclude titles watched by any household member" do
      household = Household.create!(name: "Test Household")
      member1 = household.add_member(name: "Alice")
      member2 = household.add_member(name: "Bob")

      # Member 1 watches some titles
      member1_watched = 3.times.map do |i|
        title = Title.create!(external_id: "alice_#{i}", name: "Alice Watched #{i}", title_type: "movie")
        member1.mark_watched(title, fully_watched: true)
        title
      end

      # Member 2 watches different titles
      member2_watched = 3.times.map do |i|
        title = Title.create!(external_id: "bob_#{i}", name: "Bob Watched #{i}", title_type: "movie")
        member2.mark_watched(title, fully_watched: true)
        title
      end

      # Create unwatched titles
      5.times { |i| Title.create!(external_id: "unwatched_#{i}", name: "Unwatched #{i}", title_type: "movie") }

      recommendations = RecommendationEngine.for_household(household)
      all_watched_ids = (member1_watched + member2_watched).map(&:id)

      recommendations.each do |rec|
        refute all_watched_ids.include?(rec.title_id),
          "Recommendation must exclude titles watched by any member"
      end
    end
  end

  describe "when title is partially watched" do
    it "may recommend partially watched titles" do
      household = Household.create!(name: "Test Household")
      member = household.add_member(name: "Test Member")

      partial_title = Title.create!(external_id: "partial", name: "Partial", title_type: "movie")
      member.mark_watched(partial_title, fully_watched: false, progress: 0.5)

      recommendations = RecommendationEngine.for_household(household)

      assert recommendations.is_a?(Enumerable),
        "Must return enumerable"
    end
  end

  describe "when title is abandoned" do
    it "may recommend abandoned titles" do
      household = Household.create!(name: "Test Household")
      member = household.add_member(name: "Test Member")

      abandoned_title = Title.create!(external_id: "abandoned", name: "Abandoned", title_type: "movie")
      member.mark_watched(abandoned_title, fully_watched: false, progress: 0.1)

      recommendations = RecommendationEngine.for_household(household)

      assert recommendations.is_a?(Enumerable),
        "Must return enumerable"
    end
  end
end
