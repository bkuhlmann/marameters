# frozen_string_literal: true

module Marameters
  # Specializes in providing keyword method parameter information only.
  class Keyword
    PATTERN = %i[key keyreq].freeze

    def initialize parameters, pattern: PATTERN, transformer: TRANSFORMER
      @parameters = parameters
      @collection = transformer.call parameters, pattern
    end

    def empty? = collection.empty?

    def kinds = collection.keys

    def name?(name) = collection.value? name

    def names = collection.values

    private

    attr_reader :parameters, :collection
  end
end
