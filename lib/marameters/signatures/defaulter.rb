# frozen_string_literal: true

module Marameters
  module Signatures
    # Computes a method parameter's default value.
    Defaulter = lambda do |value, passthrough: "*"|
      case value
        when /\A#{Regexp.escape passthrough}/ then value.delete_prefix passthrough
        when String then value.dump
        when Symbol then value.inspect
        when nil then "nil"
        else value
      end
    end
  end
end
