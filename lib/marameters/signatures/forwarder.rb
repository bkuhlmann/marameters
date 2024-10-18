# frozen_string_literal: true

module Marameters
  module Signatures
    # Builds single argument of super method's signature for argument forwarding.
    Forwarder = lambda do |kind, name = nil|
      case kind
        when :req, :opt then name
        when :rest then "*"
        when :keyreq, :key then "#{name}:"
        when :keyrest then "**"
        when :block then "&"
        else fail ArgumentError, "Unable to forward unknown kind: #{kind.inspect}."
      end
    end
  end
end
