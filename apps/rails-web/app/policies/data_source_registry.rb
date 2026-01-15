# frozen_string_literal: true

# DataSourceRegistry tracks all data sources used by the system.
#
# Invariants satisfied:
# - Only uses public APIs or crowd-sourced data
# - No authenticated endpoints
# - No scraped data
module DataSourceRegistry
  class << self
    def all
      [
        DataSource.new(
          name: "user_observations",
          source_type: :crowd_sourced,
          requires_authentication: false,
          uses_platform_credentials: false
        ),
        DataSource.new(
          name: "public_catalog_api",
          source_type: :public_api,
          requires_authentication: false,
          uses_platform_credentials: false
        )
      ]
    end

    def stores
      [
        DataStore.new(
          name: "availability_observations",
          contains_scraped_catalog: false
        ),
        DataStore.new(
          name: "viewing_records",
          contains_scraped_catalog: false
        )
      ]
    end
  end

  class DataSource
    attr_reader :name, :source_type

    def initialize(name:, source_type:, requires_authentication:, uses_platform_credentials:)
      @name = name
      @source_type = source_type
      @requires_authentication = requires_authentication
      @uses_platform_credentials = uses_platform_credentials
    end

    def requires_authentication?
      @requires_authentication
    end

    def uses_platform_credentials?
      @uses_platform_credentials
    end
  end

  class DataStore
    attr_reader :name

    def initialize(name:, contains_scraped_catalog:)
      @name = name
      @contains_scraped_catalog = contains_scraped_catalog
    end

    def contains_scraped_catalog?
      @contains_scraped_catalog
    end
  end
end
