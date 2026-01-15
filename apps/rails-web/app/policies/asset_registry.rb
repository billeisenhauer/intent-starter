# frozen_string_literal: true

# AssetRegistry tracks platform-related assets and their usage permissions.
#
# Invariants satisfied:
# - No platform logos without permission
# - Only generic assets used
module AssetRegistry
  class << self
    def platform_related
      [
        Asset.new(
          name: "generic_streaming_icon",
          is_generic: true,
          usage_permitted: true
        )
        # No platform-specific logos
      ]
    end
  end

  class Asset
    attr_reader :name

    def initialize(name:, is_generic:, usage_permitted:)
      @name = name
      @is_generic = is_generic
      @usage_permitted = usage_permitted
    end

    def is_generic?
      @is_generic
    end

    def usage_permitted?
      @usage_permitted
    end
  end
end
