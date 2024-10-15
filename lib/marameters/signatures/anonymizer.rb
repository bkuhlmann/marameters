# frozen_string_literal: true

module Marameters
  module Signatures
    # Ensures keywords, single splats, double splats, and blocks are anonymized for forwarding.
    Anonymizer = lambda do |*collection|
      collection.delete_if { |item| item in :nokey, * }

      collection.map do |kind, name|
        case kind
          when :keyreq, :key then [:keyrest]
          when :rest, :keyrest, :block then [kind]
          else [kind, name]
        end
      end
    end
  end
end
