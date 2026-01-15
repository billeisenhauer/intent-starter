# frozen_string_literal: true

# Invariant: Every recommendation must have explainable reasons visible to users.
#
# This evaluation verifies that recommendations are never opaque - users must
# always understand WHY something is being recommended to them.

require "minitest/autorun"

describe "Recommendation Explainability Invariant" do
  before do
    ViewingRecord.delete_all
    AvailabilityObservation.delete_all
    Subscription.delete_all
    Member.delete_all
    Household.delete_all
    Title.delete_all
  end

  describe "when recommendations are generated" do
    it "must include at least one reason for each recommendation" do
      household = create_household_with_history(titles_watched: 10)
      5.times { |i| Title.create!(external_id: "rec_#{i}", name: "Rec #{i}", title_type: "movie") }

      recommendations = RecommendationEngine.for_household(household)

      recommendations.each do |rec|
        assert rec.respond_to?(:reasons),
          "Recommendation must expose reasons"
        refute_empty rec.reasons,
          "Recommendation must have at least one reason"
      end
    end

    it "must provide human-readable reason text" do
      household = create_household_with_history(titles_watched: 10)
      5.times { |i| Title.create!(external_id: "rec_#{i}", name: "Rec #{i}", title_type: "movie") }

      recommendations = RecommendationEngine.for_household(household)

      recommendations.each do |rec|
        rec.reasons.each do |reason|
          assert reason.respond_to?(:text) || reason.is_a?(String),
            "Reason must be a string or respond to :text"

          reason_text = reason.respond_to?(:text) ? reason.text : reason
          assert reason_text.length > 0,
            "Reason text must not be empty"
          assert reason_text.length < 500,
            "Reason text should be concise (under 500 chars)"
        end
      end
    end

    it "must not use internal jargon in reasons" do
      household = create_household_with_history(titles_watched: 10)
      5.times { |i| Title.create!(external_id: "rec_#{i}", name: "Rec #{i}", title_type: "movie") }

      recommendations = RecommendationEngine.for_household(household)
      forbidden_terms = %w[vector embedding cosine similarity score matrix coefficient]

      recommendations.each do |rec|
        rec.reasons.each do |reason|
          reason_text = reason.respond_to?(:text) ? reason.text : reason.to_s
          reason_lower = reason_text.downcase

          forbidden_terms.each do |term|
            refute reason_lower.include?(term),
              "Reason should not contain internal jargon '#{term}': #{reason_text}"
          end
        end
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
