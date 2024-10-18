# frozen_string_literal: true

module Marameters
  module Signatures
    # Builds single argument of super method's signature for argument forwarding.
    Forwarder = lambda do |kind, name = nil|
      case kind
        when :req, :opt then name
        when :rest then "*#{name}"
        when :keyreq, :key then "#{name}:"
        when :keyrest then "**#{name}"
        when :block then "&#{name}"
        else fail ArgumentError, "Unable to forward unknown kind: #{kind.inspect}."
      end
    end
  end
end
