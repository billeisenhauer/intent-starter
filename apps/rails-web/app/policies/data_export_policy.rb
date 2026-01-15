# frozen_string_literal: true

# DataExportPolicy defines data export boundaries.
#
# Invariants satisfied:
# - No viewing behavior shared with advertisers
module DataExportPolicy
  class << self
    def configured_exports
      [
        ExportConfig.new(
          name: "user_data_export",
          destination_is_advertiser: false,
          includes_viewing_behavior: true,
          is_commercial: false
        )
      ]
    end
  end

  class ExportConfig
    attr_reader :name

    def initialize(name:, destination_is_advertiser:, includes_viewing_behavior:, is_commercial:)
      @name = name
      @destination_is_advertiser = destination_is_advertiser
      @includes_viewing_behavior = includes_viewing_behavior
      @is_commercial = is_commercial
    end

    def destination_is_advertiser?
      @destination_is_advertiser
    end

    def includes_viewing_behavior?
      @includes_viewing_behavior
    end

    def is_commercial?
      @is_commercial
    end
  end
end
