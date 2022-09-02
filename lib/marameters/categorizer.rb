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
      parameters.each.with_index { |pair, index| filter pair, arguments[index] }
    end

    def filter pair, value
      case pair
        in [:rest] | [:rest, :*] then splat_positional value
        in [:keyrest] | [:keyrest, :**] then record.keywords = Hash value
        in [:req, *] | [:opt, *] then record.positionals.append value
        in [:rest, *] then record.positionals.append(*value)
        in [:keyreq, *] | [:key, *] then record.keywords.merge! value if value
        in [:keyrest, *] then record.keywords.merge!(**value) if value
        in [:block, *] then record.block = value
        else fail ArgumentError, "Invalid parameter kind: #{pair.first.inspect}."
      end
    rescue TypeError
      raise TypeError, "#{value.inspect} is an invalid #{pair.first.inspect} value."
    end

    def splat_positional value
      return unless value

      record.positionals = value.is_a?(Array) ? value : [value]
    end
  end
end
