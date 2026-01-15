# frozen_string_literal: true

# RevenuePolicy defines revenue source boundaries.
#
# Invariants satisfied:
# - No advertising-based revenue
module RevenuePolicy
  class << self
    def sources
      [
        RevenueSource.new(
          name: "subscription",
          is_advertising_based: false
        )
      ]
    end
  end

  class RevenueSource
    attr_reader :name

    def initialize(name:, is_advertising_based:)
      @name = name
      @is_advertising_based = is_advertising_based
    end

    def is_advertising_based?
      @is_advertising_based
    end
  end
end
