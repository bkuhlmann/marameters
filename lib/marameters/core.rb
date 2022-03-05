# frozen_string_literal: true

module Marameters
  # Provides access to method arguments for meta-programming and/or debugging purposes.
  class Core
    # Order matters.
    DELEGATES = {positional: Positional, keyword: Keyword, splat: Splat}.freeze

    # :reek:TooManyStatements
    def self.of klass, name, collection: []
      method = klass.instance_method name

      return collection unless method

      collection << new(method.parameters)
      super_method = method.super_method
      of super_method.owner, super_method.name, collection:
    rescue NameError
      collection
    end

    def initialize parameters, delegates: DELEGATES
      @parameters = parameters

      @delegates = delegates.reduce({}) do |accumulator, (key, klass)|
        accumulator.merge key => klass.new(parameters)
      end
    end

    def empty? = parameters.empty?

    def keyword?(name) = keyword.name? name

    def keywords = keyword.names

    def kinds = delegates.values.reduce([]) { |collection, delegate| collection + delegate.kinds }

    def named_single_splat_only? = splat.named_single_only?

    def names = delegates.values.reduce([]) { |collection, delegate| collection + delegate.names }

    def positional? = !positional.empty?

    def positionals = positional.names

    def slice collection, keys:
      collection.select { |key| !keys.include?(key) || keyword.names.include?(key) }
    end

    def to_a = parameters

    def unnamed_splats_only? = splat.unnamed_only?

    private

    attr_reader :parameters, :delegates

    def keyword = delegates.fetch(__method__)

    def splat = delegates.fetch(__method__)

    def positional = delegates.fetch(__method__)
  end
end
