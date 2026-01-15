# frozen_string_literal: true

# Invariant: System must not sell ads based on personal data.
#
# This evaluation verifies that user data is never monetized through advertising.

require "minitest/autorun"

describe "No Ad Sales Invariant" do
  describe "data monetization boundaries" do
    it "must not expose user data to ad networks" do
      integrations = ExternalIntegrationRegistry.all

      ad_network_types = [:ad_network, :advertising, :programmatic_ads, :ad_exchange]

      integrations.each do |integration|
        refute ad_network_types.include?(integration.type),
          "Integration #{integration.name} must not be an ad network"
      end
    end

    it "must not include ad tracking pixels" do
      tracking_elements = TrackingRegistry.all

      tracking_elements.each do |tracker|
        refute tracker.is_ad_tracker?,
          "Tracker #{tracker.name} must not be an ad tracker"
      end
    end

    it "must not share viewing behavior with advertisers" do
      data_exports = DataExportPolicy.configured_exports

      data_exports.each do |export|
        refute export.destination_is_advertiser?,
          "Data export #{export.name} must not go to advertisers"
        refute export.includes_viewing_behavior? && export.is_commercial?,
          "Viewing behavior must not be exported commercially"
      end
    end
  end

  describe "revenue model" do
    it "must not derive revenue from ad sales" do
      revenue_sources = RevenuePolicy.sources

      revenue_sources.each do |source|
        refute source.is_advertising_based?,
          "Revenue source #{source.name} must not be advertising-based"
      end
    end

    it "must not display third-party advertisements" do
      display_policies = DisplayPolicy.ad_policies

      display_policies.each do |policy|
        refute policy.allows_third_party_ads?,
          "Display policy must not allow third-party ads"
      end
    end
  end

  describe "personal data protection" do
    it "must not build advertising profiles from user data" do
      user_profiles = UserProfilePolicy.profile_types

      user_profiles.each do |profile_type|
        refute profile_type.is_advertising_profile?,
          "User profile type #{profile_type.name} must not be an advertising profile"
      end
    end

    it "must not sell or rent user data" do
      data_policies = DataPolicy.monetization_policies

      data_policies.each do |policy|
        refute policy.allows_data_sale?,
          "Policy must not allow data sale"
        refute policy.allows_data_rental?,
          "Policy must not allow data rental"
      end
    end
  end
end
