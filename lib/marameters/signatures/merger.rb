# frozen_string_literal: true

module Marameters
  module Signatures
    # Merges the ancestor and descendant method signatures into a single signature.
    class Merger
      def initialize anonymizer: Signatures::Anonymizer, reducer: Signatures::Reducer, kinds: KINDS
        @anonymizer = anonymizer
        @reducer = reducer
        @kinds = kinds
      end

      def call ancestor, descendant
        anonymizer.call(*ancestor)
                  .then { |anonymized| reducer.call anonymized, descendant }
                  .sort_by! { |(kind, *)| kinds.index kind }
      end

      private

      attr_reader :anonymizer, :reducer, :kinds
    end
  end
end
