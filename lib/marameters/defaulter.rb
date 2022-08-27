# frozen_string_literal: true

module Marameters
  # Computes a method parameter's default value.
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
