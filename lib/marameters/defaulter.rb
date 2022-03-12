# frozen_string_literal: true

module Marameters
  # Calculates the default for a given value when used within a method's parameter.
  class Defaulter
    PASSTHROUGH = "*"

    def self.call(...) = new(...).call

    def initialize value, passthrough: PASSTHROUGH
      @value = value
      @passthrough = passthrough
    end

    def call
      case value
        when nil then "nil"
        when /\A#{Regexp.escape passthrough}/ then value.delete_prefix passthrough
        when String then value.dump
        when Symbol then value.inspect
        else value
      end
    end

    private

    attr_reader :value, :passthrough
  end
end
