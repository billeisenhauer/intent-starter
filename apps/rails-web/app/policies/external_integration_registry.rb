# frozen_string_literal: true

# ExternalIntegrationRegistry tracks all external integrations.
#
# Invariants satisfied:
# - No ad network integrations
module ExternalIntegrationRegistry
  class << self
    def all
      [
        Integration.new(
          name: "analytics",
          type: :first_party_analytics
        )
        # No ad networks
      ]
    end
  end

  class Integration
    attr_reader :name, :type

    def initialize(name:, type:)
      @name = name
      @type = type
    end
  end
end
