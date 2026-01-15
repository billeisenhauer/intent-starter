# frozen_string_literal: true

# Invariant: Recommendations must include a minimum of 3 options when sufficient
# data exists; cold start and new user onboarding may return fewer.
#
# This evaluation verifies that the recommendation engine honors the minimum
# threshold while gracefully handling insufficient data scenarios.

require "minitest/autorun"

describe "Recommendation Minimum Invariant" do
  before do
    # Clean up before each test
    ViewingRecord.delete_all
    AvailabilityObservation.delete_all
    Subscription.delete_all
    Member.delete_all
    Household.delete_all
    Title.delete_all
  end

  describe "when household has sufficient viewing history" do
    it "must return at least 3 recommendations" do
      # Arrange: household with established viewing history
      household = create_household_with_history(titles_watched: 10)

      # Create some titles to recommend
      15.times { |i| Title.create!(external_id: "rec_#{i}", name: "Rec Title #{i}", title_type: "movie") }

      # Act: request recommendations
      recommendations = RecommendationEngine.for_household(household)

      # Assert: minimum threshold met
      assert recommendations.count >= 3,
        "Expected at least 3 recommendations for established household, got #{recommendations.count}"
    end

    it "must return recommendations with confidence displayed" do
      household = create_household_with_history(titles_watched: 10)
      5.times { |i| Title.create!(external_id: "rec_#{i}", name: "Rec Title #{i}", title_type: "movie") }

      recommendations = RecommendationEngine.for_household(household)

      recommendations.each do |rec|
        assert rec.respond_to?(:confidence),
          "Recommendation must expose confidence"
        refute_nil rec.confidence,
          "Confidence must not be nil"
      end
    end
  end

  describe "when household is in cold start" do
    it "may return fewer than 3 recommendations" do
      # Arrange: brand new household with no history
      household = create_household_with_history(titles_watched: 0)

      # Act: request recommendations
      recommendations = RecommendationEngine.for_household(household)

      # Assert: graceful degradation - no assertion on minimum
      # System should not crash or error, may return 0-2 recommendations
      assert recommendations.is_a?(Enumerable),
        "Must return enumerable even in cold start"
    end

    it "must not crash when no data exists" do
      household = create_household_with_history(titles_watched: 0)

      # Should not raise
      recommendations = RecommendationEngine.for_household(household)

      assert_kind_of Enumerable, recommendations
    end
  end

  describe "when household has minimal history" do
    it "may return fewer than 3 if insufficient signal exists" do
      # Arrange: household with only 1-2 titles watched
      household = create_household_with_history(titles_watched: 2)

      # Act: request recommendations
      recommendations = RecommendationEngine.for_household(household)

      # Assert: system handles gracefully
      assert recommendations.is_a?(Enumerable),
        "Must return enumerable even with minimal history"
    end
  end

  # --- Test Helpers ---

  def create_household_with_history(titles_watched:)
    household = Household.create!(name: "Test Household")
    member = household.add_member(name: "Test Member")

    titles_watched.times do |i|
      title = Title.create!(
        external_id: "watched_#{SecureRandom.hex(4)}",
        name: "Watched Title #{i}",
        title_type: %w[movie series].sample
      )
      member.mark_watched(title, fully_watched: true)
    end

    household
  end
end
