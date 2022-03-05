# frozen_string_literal: true

module Marameters
  # Specializes in providing positional method paratemer information only.
  class Positional
    PATTERN = %i[req opt].freeze

    def initialize parameters, pattern: PATTERN, transformer: TRANSFORMER
      @parameters = parameters
      @collection = transformer.call parameters, pattern
    end

    def empty? = collection.empty?

    def kinds = collection.keys

    def names = collection.values

    private

    attr_reader :parameters, :collection
  end
end
