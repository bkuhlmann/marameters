# frozen_string_literal: true

module Marameters
  module Signatures
    # Blends super and sub method parameters together while allowing default overrides.
    class Inheritor
      def initialize key_length: 1, kinds: KINDS
        @key_length = key_length
        @kinds = kinds
        freeze
      end

      def call ancestor, descendant
        merge(ancestor, descendant).values.sort_by! { |(kind, *)| kinds.index kind }
      end

      private

      attr_reader :key_length, :kinds

      def merge ancestor, descendant
        ancestor.to_a.union(descendant.to_a).each.with_object({}) do |parameter, all|
          key = parameter[..key_length]
          kind = key.first

          case kind
            when :req, :opt then all[key] = parameter if descendant.positionals_and_maybe_keywords?
            when :keyreq, :key
              all[:keyrest] = [:keyrest] if ancestor.keywords?
              all[key] = parameter if descendant.include? parameter
            else all[kind] = parameter
          end
        end
      end
    end
  end
end
