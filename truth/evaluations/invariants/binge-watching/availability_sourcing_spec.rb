# frozen_string_literal: true

# Invariant: Availability data must be probabilistic and crowd-sourced,
# never scraped from behind auth walls.
#
# This evaluation verifies that the system only uses legally clean data sources
# and represents availability as probabilistic rather than authoritative.

require "minitest/autorun"

describe "Availability Sourcing Invariant" do
  before do
    ViewingRecord.delete_all
    AvailabilityObservation.delete_all
    Subscription.delete_all
    Member.delete_all
    Household.delete_all
    Title.delete_all
  end

  describe "availability representation" do
    it "must represent availability as probabilistic" do
      title = Title.create!(external_id: "test", name: "Test", title_type: "movie")
      household = Household.create!(name: "Test")
      member = household.add_member(name: "Observer")

      # Add some observations
      AvailabilityObservation.create!(
        title: title,
        platform: "Netflix",
        observer: member,
        confidence: 0.9,
        observed_at: Time.current
      )

      availability = AvailabilityService.for_title(title)

      assert availability.respond_to?(:confidence),
        "Availability must have confidence score"
      assert availability.confidence >= 0.0 && availability.confidence <= 1.0,
        "Confidence must be between 0.0 and 1.0"
    end

    it "must not claim authoritative availability" do
      title = Title.create!(external_id: "test", name: "Test", title_type: "movie")
      availability = AvailabilityService.for_title(title)

      refute availability.respond_to?(:authoritative?) && availability.authoritative?,
        "Availability must not claim to be authoritative"

      if availability.respond_to?(:description)
        forbidden_phrases = ["definitely available", "guaranteed", "official"]
        forbidden_phrases.each do |phrase|
          refute availability.description.downcase.include?(phrase),
            "Availability description must not claim certainty: #{phrase}"
        end
      end
    end

    it "must include last-verified timestamp" do
      title = Title.create!(external_id: "test", name: "Test", title_type: "movie")
      household = Household.create!(name: "Test")
      member = household.add_member(name: "Observer")

      AvailabilityObservation.create!(
        title: title,
        platform: "Netflix",
        observer: member,
        confidence: 0.9,
        observed_at: Time.current
      )

      availability = AvailabilityService.for_title(title)

      assert availability.respond_to?(:last_verified_at),
        "Availability must track when it was last verified"
      refute_nil availability.last_verified_at,
        "Last verified timestamp must not be nil"
    end
  end

  describe "data sourcing" do
    it "must only use crowd-sourced observations" do
      title = Title.create!(external_id: "test", name: "Test", title_type: "movie")
      availability = AvailabilityService.for_title(title)

      assert availability.respond_to?(:source),
        "Availability must expose its source"
      assert_equal :crowd_sourced, availability.source,
        "Availability source must be crowd-sourced"
    end

    it "must track observation count" do
      title = Title.create!(external_id: "test", name: "Test", title_type: "movie")
      availability = AvailabilityService.for_title(title)

      assert availability.respond_to?(:observation_count),
        "Availability must track observation count"
      assert availability.observation_count >= 0,
        "Observation count must be non-negative"
    end

    it "must not use scraped data" do
      title = Title.create!(external_id: "test", name: "Test", title_type: "movie")
      availability = AvailabilityService.for_title(title)

      forbidden_sources = [:scrape, :scraped, :crawl, :crawled, :automated_fetch]

      if availability.respond_to?(:source)
        refute forbidden_sources.include?(availability.source),
          "Availability must not use scraped data"
      end
    end
  end

  describe "confidence degradation" do
    it "must reduce confidence for stale data" do
      title = Title.create!(external_id: "test", name: "Test", title_type: "movie")
      household = Household.create!(name: "Test")
      member = household.add_member(name: "Observer")

      # Create observation from 30 days ago
      AvailabilityObservation.create!(
        title: title,
        platform: "Netflix",
        observer: member,
        confidence: 0.9,
        observed_at: 30.days.ago
      )

      fresh_availability = AvailabilityService.for_title(title, as_of: 30.days.ago)
      stale_availability = AvailabilityService.for_title(title, as_of: Time.current)

      assert stale_availability.confidence <= fresh_availability.confidence,
        "Stale availability should have equal or lower confidence"
    end
  end
end
