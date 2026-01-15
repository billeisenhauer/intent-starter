# frozen_string_literal: true

# UserProfilePolicy defines user profile boundaries.
#
# Invariants satisfied:
# - No advertising profiles
module UserProfilePolicy
  class << self
    def profile_types
      [
        ProfileType.new(
          name: "viewing_preferences",
          is_advertising_profile: false
        )
      ]
    end
  end

  class ProfileType
    attr_reader :name

    def initialize(name:, is_advertising_profile:)
      @name = name
      @is_advertising_profile = is_advertising_profile
    end

    def is_advertising_profile?
      @is_advertising_profile
    end
  end
end
