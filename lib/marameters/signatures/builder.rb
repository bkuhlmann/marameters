# frozen_string_literal: true

module Marameters
  module Signatures
    # Builds a single parameter for a method's signature.
    class Builder
      def initialize defaulter: Defaulter
        @defaulter = defaulter
        freeze
      end

      def call kind, name = nil, default: nil
        case kind
          when :req then name
          when :opt then "#{name} = #{defaulter.call default}"
          when :rest then "*#{name}"
          when :nokey then "**nil"
          when :keyreq then "#{name}:"
          when :key then "#{name}: #{defaulter.call default}"
          when :keyrest then "**#{name}"
          when :block then "&#{name}"
          else fail ArgumentError, "Wrong kind (#{kind}), name (#{name}), or default (#{default})."
        end
      end

      private

      attr_reader :defaulter
    end
  end
end
