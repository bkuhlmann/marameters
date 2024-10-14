# frozen_string_literal: true

require "forwardable"

module Marameters
  # Provides information on a method's parameters.
  class Probe
    extend Forwardable

    CATEGORIES = {positionals: %i[req opt], keywords: %i[keyreq key]}.freeze

    def self.of klass, name, collection: []
      method = klass.instance_method name
      collection << new(method.parameters)
      super_method = method.super_method
      of super_method.owner, super_method.name, collection:
    rescue NameError
      collection
    end

    attr_reader :keywords, :positionals

    delegate %i[deconstruct empty? to_a to_ary] => :parameters

    def initialize parameters, categories: CATEGORIES
      @parameters = parameters
      categories.each { |category, kinds| define_variable category, kinds }
    end

    def keywords_for(*keys, **attributes)
      attributes.select { |key| !keys.include?(key) || keywords.include?(key) }
    end

    def kind?(value) = parameters.any? { |kind, _name| kind == value }

    def kinds = parameters.map { |kind, _name| kind }

    def name?(value) = parameters.any? { |_kind, name| name == value }

    def names = parameters.map { |_kind, name| name }

    def only_bare_splats?
      parameters in [[:rest]] \
                    | [[:keyrest]] \
                    | [[:rest], [:keyrest]] \
                    | [[:rest, :*]] \
                    | [[:keyrest, :**]] \
                    | [[:rest, :*], [:keyrest, :**]]
    end

    def only_double_splats? = (parameters in [[:keyrest]] | [[:keyrest, *]])

    def only_single_splats? = (parameters in [[:rest]] | [[:rest, *]])

    def positionals? = positionals.any?

    private

    attr_reader :parameters

    def define_variable category, kinds
      parameters.filter_map { |kind, name| next name if kinds.include? kind }
                .then { |collection| instance_variable_set :"@#{category}", collection }
    end
  end
end
