# frozen_string_literal: true

module Marameters
  # Provides information on a method's parameters.
  class Probe
    CATEGORIES = {
      positionals: %i[req opt],
      keywords: %i[keyreq key],
      splats: %i[rest keyrest]
    }.freeze

    def self.of klass, name, collection: []
      method = klass.instance_method name
      collection << new(method.parameters)
      super_method = method.super_method
      of super_method.owner, super_method.name, collection:
    rescue NameError
      collection
    end

    attr_reader :keywords, :positionals, :splats

    def initialize parameters, categories: CATEGORIES
      @parameters = parameters
      categories.each { |category, kinds| define_variable category, kinds }
    end

    def block = parameters.find { |kind, name| break name if kind == :block }

    def block? = (parameters in [*, [:block, *]])

    def empty? = parameters.empty?

    def keyword_slice collection, keys:
      collection.select { |key| !keys.include?(key) || keywords.include?(key) }
    end

    def keywords? = keywords.any?

    def kind?(value) = parameters.any? { |kind, _name| kind == value }

    def kinds = parameters.map { |kind, _name| kind }

    def name?(value) = parameters.any? { |_kind, name| name == value }

    def names = parameters.map { |_kind, name| name }

    # rubocop:todo Style/RedundantLineContinuation
    def only_bare_splats?
      parameters in [[:rest]] \
                    | [[:keyrest]] \
                    | [[:rest], [:keyrest]] \
                    | [[:rest, :*]] \
                    | [[:keyrest, :**]] \
                    | [[:rest, :*], [:keyrest, :**]]
    end
    # rubocop:enable Style/RedundantLineContinuation

    def only_double_splats? = (parameters in [[:keyrest]] | [[:keyrest, *]])

    def only_single_splats? = (parameters in [[:rest]] | [[:rest, *]])

    def positionals? = positionals.any?

    def splats? = splats.any?

    def to_a = parameters

    private

    attr_reader :parameters

    def define_variable category, kinds
      parameters.filter_map { |kind, name| next name if kinds.include? kind }
                .then { |collection| instance_variable_set :"@#{category}", collection }
    end
  end
end
