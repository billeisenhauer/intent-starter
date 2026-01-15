# frozen_string_literal: true

# AvailabilityService aggregates crowd-sourced availability data.
#
# Invariants satisfied:
# - Availability is probabilistic, not authoritative
# - Data is crowd-sourced only, never scraped
# - Confidence degrades with staleness
module AvailabilityService
  CONFIDENCE_THRESHOLD = 0.3
  STALENESS_WINDOW = 30.days

  class << self
    # Get availability info for a title
    def for_title(title, as_of: Time.current)
      observations = title.availability_observations
                          .where("observed_at >= ?", as_of - STALENESS_WINDOW)

      platforms_data = aggregate_by_platform(observations, as_of)

      Availability.new(
        title: title,
        platforms_data: platforms_data,
        last_verified_at: observations.maximum(:observed_at),
        observation_count: observations.count,
        as_of: as_of
      )
    end

    private

    def aggregate_by_platform(observations, as_of)
      observations.group_by(&:platform).transform_values do |platform_obs|
        calculate_platform_confidence(platform_obs, as_of)
      end
    end

    def calculate_platform_confidence(observations, as_of)
      return 0.0 if observations.empty?

      # Weight recent observations more heavily
      total_weight = 0.0
      weighted_confidence = 0.0

      observations.each do |obs|
        days_old = ((as_of - obs.observed_at) / 1.day).to_f
        freshness_weight = [1.0 - (days_old / STALENESS_WINDOW.to_i), 0.1].max

        weighted_confidence += obs.confidence * freshness_weight
        total_weight += freshness_weight
      end

      return 0.0 if total_weight.zero?

      weighted_confidence / total_weight
    end
  end

  # Availability value object
  class Availability
    attr_reader :title, :last_verified_at, :observation_count

    def initialize(title:, platforms_data:, last_verified_at:, observation_count:, as_of:)
      @title = title
      @platforms_data = platforms_data
      @last_verified_at = last_verified_at
      @observation_count = observation_count
      @as_of = as_of
    end

    # Overall confidence (max across platforms)
    def confidence
      return 0.0 if @platforms_data.empty?

      @platforms_data.values.max
    end

    # Source is always crowd-sourced (invariant)
    def source
      :crowd_sourced
    end

    # Never authoritative (invariant)
    def authoritative?
      false
    end

    # Platforms where title is likely available
    def platforms
      @platforms_data.select { |_, conf| conf >= CONFIDENCE_THRESHOLD }.keys
    end

    # Get confidence for a specific platform
    def confidence_for(platform)
      @platforms_data[platform] || 0.0
    end

    # Description (invariant: no certainty claims)
    def description
      if platforms.empty?
        "Availability uncertain - no recent observations"
      elsif platforms.size == 1
        "Likely available on #{platforms.first}"
      else
        "Likely available on #{platforms.join(', ')}"
      end
    end

    # Support hash-like iteration
    def each
      return enum_for(:each) unless block_given?

      @platforms_data.each do |platform, confidence|
        yield platform, {
          confidence: confidence,
          observation_count: @observation_count,
          last_confirmed: @last_verified_at
        }
      end
    end

    def map(&block)
      each.map(&block)
    end

    def empty?
      @platforms_data.empty?
    end
  end
end
