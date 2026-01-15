# frozen_string_literal: true

# RecommendationEngine generates personalized recommendations for households.
#
# Invariants satisfied:
# - Minimum 3 recommendations when sufficient data exists
# - Confidence displayed to users
# - Explainable reasons for every recommendation
# - No re-recommending fully watched titles
module RecommendationEngine
  MINIMUM_RECOMMENDATIONS = 3
  MINIMUM_HISTORY_FOR_FULL_RECOMMENDATIONS = 5

  class << self
    # Generate recommendations for a household
    # Returns an array of Recommendation objects
    def for_household(household)
      excluded_title_ids = fully_watched_title_ids(household)
      available_titles = Title.where.not(id: excluded_title_ids)

      # Check if we have enough history for full recommendations
      history_count = household.viewing_records.count
      has_sufficient_history = history_count >= MINIMUM_HISTORY_FOR_FULL_RECOMMENDATIONS

      recommendations = generate_recommendations(
        household: household,
        available_titles: available_titles,
        has_sufficient_history: has_sufficient_history
      )

      recommendations
    end

    private

    def fully_watched_title_ids(household)
      household.fully_watched_titles.pluck(:id)
    end

    def generate_recommendations(household:, available_titles:, has_sufficient_history:)
      # Get viewing history for taste analysis
      watched_titles = household.all_watched_titles.includes(:viewing_records)

      # Score available titles based on household preferences
      scored_titles = available_titles.map do |title|
        score = calculate_score(title, watched_titles, household)
        reasons = generate_reasons(title, watched_titles, household)
        confidence = calculate_confidence(score, has_sufficient_history)

        Recommendation.new(
          title: title,
          confidence: confidence,
          reasons: reasons
        )
      end

      # Sort by confidence and return top recommendations
      sorted = scored_titles.sort_by { |r| -r.confidence.value }

      # Apply minimum threshold if sufficient history
      if has_sufficient_history
        sorted.first([sorted.size, MINIMUM_RECOMMENDATIONS].max)
      else
        sorted.first(sorted.size) # Return whatever we have
      end
    end

    def calculate_score(title, watched_titles, household)
      return 0.5 if watched_titles.empty?

      # Simple scoring based on title type match
      watched_types = watched_titles.pluck(:title_type).tally
      most_watched_type = watched_types.max_by { |_, count| count }&.first

      base_score = 0.5
      base_score += 0.3 if title.title_type == most_watched_type

      # Boost if title is available on a subscribed platform
      subscribed_platforms = household.subscriptions.active.pluck(:platform)
      availability = AvailabilityService.for_title(title)

      if availability.platforms.any? { |p| subscribed_platforms.include?(p) }
        base_score += 0.2
      end

      [base_score, 1.0].min
    end

    def generate_reasons(title, watched_titles, household)
      reasons = []

      # Type-based reason
      watched_types = watched_titles.pluck(:title_type).tally
      most_watched_type = watched_types.max_by { |_, count| count }&.first

      if title.title_type == most_watched_type
        type_label = most_watched_type == "movie" ? "movies" : "TV series"
        reasons << Reason.new("You frequently watch #{type_label}")
      end

      # Availability reason
      subscribed_platforms = household.subscriptions.active.pluck(:platform)
      availability = AvailabilityService.for_title(title)
      matching_platforms = availability.platforms & subscribed_platforms

      if matching_platforms.any?
        reasons << Reason.new("Available on #{matching_platforms.first}")
      end

      # Default reason if none generated
      if reasons.empty?
        reasons << Reason.new("Popular title you haven't watched yet")
      end

      reasons
    end

    def calculate_confidence(score, has_sufficient_history)
      # Reduce confidence if insufficient history
      adjusted_score = has_sufficient_history ? score : score * 0.6

      Confidence.new(adjusted_score)
    end
  end

  # Recommendation value object
  class Recommendation
    attr_reader :title, :confidence, :reasons

    def initialize(title:, confidence:, reasons:)
      @title = title
      @confidence = confidence
      @reasons = reasons
    end

    def title_id
      title.id
    end

    # For comparison/sorting
    def <=>(other)
      confidence <=> other.confidence
    end
  end

  # Confidence value object
  # Supports multiple display formats as per invariant
  class Confidence
    attr_reader :value

    def initialize(value)
      @value = [[value, 0.0].max, 1.0].min
    end

    def to_s
      to_label
    end

    def to_display
      to_label
    end

    # Comparable for sorting
    def <=>(other)
      value <=> other.value
    end

    def confidence_rank
      case value
      when 0.8..1.0 then 1
      when 0.6...0.8 then 2
      when 0.4...0.6 then 3
      else 4
      end
    end

    # Human-readable label (invariant: no certainty claims)
    def to_label
      case value
      when 0.8..1.0 then "Strong Match"
      when 0.6...0.8 then "Good Match"
      when 0.4...0.6 then "Fair Match"
      else "Possible Match"
      end
    end
  end

  # Reason value object
  class Reason
    attr_reader :text

    def initialize(text)
      @text = text
    end

    def to_s
      text
    end
  end
end
