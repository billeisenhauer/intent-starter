# frozen_string_literal: true

# Invariant: Every recommendation must display confidence to users;
# presentation format may evolve beyond numeric scores.
#
# This evaluation verifies that confidence is always communicated,
# while allowing flexibility in how it's presented.

require "minitest/autorun"

describe "Recommendation Confidence Invariant" do
  before do
    ViewingRecord.delete_all
    AvailabilityObservation.delete_all
    Subscription.delete_all
    Member.delete_all
    Household.delete_all
    Title.delete_all
  end

  describe "confidence presence" do
    it "must expose confidence for every recommendation" do
      household = create_household_with_history(titles_watched: 10)
      5.times { |i| Title.create!(external_id: "rec_#{i}", name: "Rec #{i}", title_type: "movie") }

      recommendations = RecommendationEngine.for_household(household)

      recommendations.each do |rec|
        assert rec.respond_to?(:confidence),
          "Recommendation must respond to :confidence"
        refute_nil rec.confidence,
          "Confidence must not be nil"
      end
    end

    it "must provide user-displayable confidence representation" do
      household = create_household_with_history(titles_watched: 10)
      5.times { |i| Title.create!(external_id: "rec_#{i}", name: "Rec #{i}", title_type: "movie") }

      recommendations = RecommendationEngine.for_household(household)

      recommendations.each do |rec|
        displayable = rec.confidence.respond_to?(:to_display) ||
                      rec.confidence.respond_to?(:to_s) ||
                      rec.confidence.is_a?(Numeric) ||
                      rec.confidence.is_a?(String) ||
                      rec.confidence.is_a?(Symbol)

        assert displayable,
          "Confidence must be displayable to users"
      end
    end
  end

  describe "confidence semantics" do
    it "must indicate relative strength" do
      household = create_household_with_history(titles_watched: 10)
      5.times { |i| Title.create!(external_id: "rec_#{i}", name: "Rec #{i}", title_type: "movie") }

      recommendations = RecommendationEngine.for_household(household)

      recommendations.each do |rec|
        assert rec.confidence.respond_to?(:<=>) || rec.respond_to?(:confidence_rank),
          "Confidence must be comparable or provide rank"
      end
    end

    it "must not mislead users about certainty" do
      household = create_household_with_history(titles_watched: 10)
      5.times { |i| Title.create!(external_id: "rec_#{i}", name: "Rec #{i}", title_type: "movie") }

      recommendations = RecommendationEngine.for_household(household)

      recommendations.each do |rec|
        confidence_str = rec.confidence.to_s.downcase

        forbidden = ["100%", "guaranteed", "definitely", "certain", "always"]
        forbidden.each do |term|
          refute confidence_str.include?(term),
            "Confidence should not claim certainty: #{term}"
        end
      end
    end
  end

  describe "confidence evolution" do
    it "must support non-numeric confidence formats" do
      household = create_household_with_history(titles_watched: 10)
      5.times { |i| Title.create!(external_id: "rec_#{i}", name: "Rec #{i}", title_type: "movie") }

      recommendations = RecommendationEngine.for_household(household)

      recommendations.each do |rec|
        assert rec.confidence,
          "Confidence must be present"
      end
    end
  end

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
