# frozen_string_literal: true

module Marameters
  module Signatures
    # Ensures duplicate parameters are removed while allowing default overrides.
    Reducer = lambda do |parameters, key_length: 1|
      forwards = {rest: false, keyrest: false, block: false}
      result = {}

      parameters.each do |item|
        key = item[..key_length].compact
        kind, name, * = item

        case kind
          when :rest, :keyrest, :block
            forwards[kind] = true unless name
            result[key] = item unless name && forwards[kind]
          else result[key] = item
        end
      end

      result.values
    end
  end
end
