# frozen_string_literal: true

# BrandingPolicy ensures we don't imply partnerships with streaming platforms.
#
# Invariants satisfied:
# - No implied partnerships
# - Includes non-affiliation disclaimers
module BrandingPolicy
  class << self
    def current
      Policy.new
    end
  end

  class Policy
    def implies_partnership?
      false
    end

    def disclaimers
      [
        "Binge Watching is not affiliated with any streaming platform",
        "All availability data is crowd-sourced and may not be accurate",
        "Platform names and logos are trademarks of their respective owners"
      ]
    end
  end
end
