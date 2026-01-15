# frozen_string_literal: true

# DataPolicy defines data monetization boundaries.
#
# Invariants satisfied:
# - No data sales
# - No data rental
# - No advertising profiles
module DataPolicy
  class << self
    def monetization_policies
      [
        MonetizationPolicy.new(
          name: "default",
          allows_data_sale: false,
          allows_data_rental: false
        )
      ]
    end
  end

  class MonetizationPolicy
    attr_reader :name

    def initialize(name:, allows_data_sale:, allows_data_rental:)
      @name = name
      @allows_data_sale = allows_data_sale
      @allows_data_rental = allows_data_rental
    end

    def allows_data_sale?
      @allows_data_sale
    end

    def allows_data_rental?
      @allows_data_rental
    end
  end
end
