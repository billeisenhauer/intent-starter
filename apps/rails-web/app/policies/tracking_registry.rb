# frozen_string_literal: true

# TrackingRegistry tracks all tracking elements.
#
# Invariants satisfied:
# - No ad tracking pixels
module TrackingRegistry
  class << self
    def all
      [
        Tracker.new(
          name: "session_tracker",
          is_ad_tracker: false
        )
        # No ad trackers
      ]
    end
  end

  class Tracker
    attr_reader :name

    def initialize(name:, is_ad_tracker:)
      @name = name
      @is_ad_tracker = is_ad_tracker
    end

    def is_ad_tracker?
      @is_ad_tracker
    end
  end
end
