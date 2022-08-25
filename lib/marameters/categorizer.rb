# frozen_string_literal: true

require "refinements/structs"

module Marameters
  # Builds the primary argument categories based on method parameters and arguments.
  class Categorizer
    using Refinements::Structs

    def initialize parameters, model: Splat
      @parameters = parameters
      @model = model
    end

    def call arguments
      @record = model.new
      map arguments
      record
    end

    private

    attr_reader :parameters, :model, :record

    def map arguments
      parameters.each.with_index { |pair, index| filter pair, arguments[index], arguments }
    end

    def filter pair, value, arguments
      case pair
        in [:rest] | [:rest, :*] then splat_positionals arguments
        in [:keyrest] | [:keyrest, :**] then splat_keywords arguments
        in [:block, :&] then forward_block arguments
        in [:req, *] then record.positionals.append value
        in [:opt, *] then record.positionals.append value if value
        in [:rest, *] then record.positionals.append(*value)
        in [:keyreq, *] | [:key, *] then record.keywords.merge! value if value
        in [:keyrest, *] then record.keywords.merge!(**value) if value
        in [:block, *] then record.block = value
        else fail ArgumentError, "Invalid parameter kind: #{pair.first.inspect}."
      end
    rescue TypeError
      raise TypeError, "#{value.inspect} is an invalid #{pair.first.inspect} value."
    end

    def splat_positionals arguments
      arguments.reject { |item| item in Hash | Proc }
               .flatten
               .then { |values| record.positionals.append(*values) }
    end

    def splat_keywords arguments
      arguments.each { |value| record.keywords.merge! value if value.is_a? Hash }
    end

    def forward_block arguments
      arguments.find { |item| item.is_a? Proc }
               .then { |block| record.block = block }
    end
  end
end
