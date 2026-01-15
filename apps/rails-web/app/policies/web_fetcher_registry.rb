# frozen_string_literal: true

# WebFetcherRegistry tracks all web fetching components.
#
# Invariants satisfied:
# - All fetchers respect robots.txt
module WebFetcherRegistry
  class << self
    def all
      [
        Fetcher.new(
          name: "public_api_client",
          respects_robots_txt: true
        )
      ]
    end
  end

  class Fetcher
    attr_reader :name

    def initialize(name:, respects_robots_txt:)
      @name = name
      @respects_robots_txt = respects_robots_txt
    end

    def respects_robots_txt?
      @respects_robots_txt
    end
  end
end
