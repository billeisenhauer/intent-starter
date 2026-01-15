# frozen_string_literal: true

# Invariant: System must not scrape protected content or imply platform partnerships.
#
# This evaluation verifies legal and ethical data sourcing boundaries.

require "minitest/autorun"

describe "No Protected Scraping Invariant" do
  describe "data collection boundaries" do
    it "must not access authenticated endpoints" do
      data_sources = DataSourceRegistry.all

      data_sources.each do |source|
        refute source.requires_authentication?,
          "Data source #{source.name} must not require authentication"
        refute source.uses_platform_credentials?,
          "Data source #{source.name} must not use platform credentials"
      end
    end

    it "must not store scraped catalog data" do
      data_stores = DataSourceRegistry.stores

      data_stores.each do |store|
        refute store.contains_scraped_catalog?,
          "Data store #{store.name} must not contain scraped catalog data"
      end
    end

    it "must only use public APIs or crowd-sourced data" do
      data_sources = DataSourceRegistry.all

      allowed_types = [:public_api, :crowd_sourced, :user_submitted, :manual_entry]

      data_sources.each do |source|
        assert allowed_types.include?(source.source_type),
          "Data source #{source.name} must be public or crowd-sourced, not #{source.source_type}"
      end
    end
  end

  describe "partnership representation" do
    it "must not imply official partnerships" do
      branding = BrandingPolicy.current

      refute branding.implies_partnership?,
        "System must not imply official partnerships with streaming platforms"

      if branding.respond_to?(:disclaimers)
        assert branding.disclaimers.any? { |d| d.include?("not affiliated") },
          "Must include non-affiliation disclaimer"
      end
    end

    it "must not use platform logos without permission" do
      assets = AssetRegistry.platform_related

      assets.each do |asset|
        assert asset.usage_permitted? || asset.is_generic?,
          "Platform asset #{asset.name} must have permitted usage or be generic"
      end
    end
  end

  describe "robots.txt compliance" do
    it "must respect robots.txt for any web fetching" do
      fetchers = WebFetcherRegistry.all

      fetchers.each do |fetcher|
        assert fetcher.respects_robots_txt?,
          "Fetcher #{fetcher.name} must respect robots.txt"
      end
    end
  end
end
