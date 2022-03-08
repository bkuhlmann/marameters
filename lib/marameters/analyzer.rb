# frozen_string_literal: true

require "refinements/arrays"

module Marameters
  # Provides analysis of a method's parameters.
  class Analyzer
    using Refinements::Arrays

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

    def initialize parameters
      @parameters = parameters
      @items = parameters.reduce({}) { |all, (kind, name)| all.merge kind => name }
    end

    def block = items[:block]

    def block? = items.key? :block

    def empty? = items.empty?

    def keyword_slice collection, keys:
      collection.select { |key| !keys.include?(key) || keywords.include?(key) }
    end

    def keywords = items.values_at(:keyreq, :key).compress!

    def keywords? = keywords.any?

    def kind?(kind) = items.key? kind

    def kinds = items.keys

    def name?(name) = items.value? name

    def names = items.values

    def only_bare_splats? = (parameters in [[:rest]] | [[:keyrest]] | [[:rest], [:keyrest]])

    def only_double_splats? = (parameters in [[:keyrest, *]])

    def only_single_splats? = (parameters in [[:rest, *]])

    def positionals = items.values_at(:req, :opt).compress!

    def positionals? = positionals.any?

    def splats = items.values_at(:rest, :keyrest).compress!

    def splats? = splats.any?

    def to_a = parameters

    def to_h = items

    private

    attr_reader :parameters, :items
  end
end
