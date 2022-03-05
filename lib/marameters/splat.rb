# frozen_string_literal: true

module Marameters
  # Specializes in providing passthrough method parameter information only.
  class Splat
    PATTERN = %i[rest keyrest].freeze

    def initialize parameters, pattern: PATTERN, transformer: TRANSFORMER
      @parameters = parameters
      @collection = transformer.call parameters, pattern
    end

    def empty? = collection.empty?

    def kinds = collection.keys

    def names = collection.values

    def named_double_only? = (parameters in [[:keyrest, *]])

    def named_single_only? = (parameters in [[:rest, *]])

    def unnamed_only? = (parameters in [[:rest]] | [[:keyrest]] | [[:rest], [:keyrest]])

    private

    attr_reader :parameters, :collection
  end
end
