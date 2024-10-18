# frozen_string_literal: true

module Marameters
  module Signatures
    # Builds single argument for super method's signature when argument forwarding.
    Forwarder = lambda do |kind, name = nil|
      case kind
        when :req, :opt then name
        when :rest then "*#{name}"
        when :nokey then ""
        when :keyreq, :key then "#{name}:"
        when :keyrest then "**#{name}"
        when :block then "&#{name}"
        else fail ArgumentError, "Unable to forward unknown kind: #{kind.inspect}."
      end
    end
  end
end
