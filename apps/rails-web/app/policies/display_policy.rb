# frozen_string_literal: true

# DisplayPolicy defines advertisement display boundaries.
#
# Invariants satisfied:
# - No third-party advertisements
module DisplayPolicy
  class << self
    def ad_policies
      [
        AdPolicy.new(
          name: "default",
          allows_third_party_ads: false
        )
      ]
    end
  end

  class AdPolicy
    attr_reader :name

    def initialize(name:, allows_third_party_ads:)
      @name = name
      @allows_third_party_ads = allows_third_party_ads
    end

    def allows_third_party_ads?
      @allows_third_party_ads
    end
  end
end
