# frozen_string_literal: true

module Marameters
  # Builds the primary argument categories based on method parameters and arguments.
  class Categorizer
    def initialize model: Models::Forward
      @model = model
    end

    def call parameters, arguments
      @record = model.new

      return record if arguments.empty?

      map parameters, arguments
    end

    private

    attr_reader :model, :record

    def map parameters, arguments
      size = arguments.size
      parameters.each.with_index { |pair, index| filter pair, arguments[index] if index < size }
      record
    end

    def filter pair, value
      case pair
        in [:rest] | [:rest, :*] then to_array value
        in [:keyrest] | [:keyrest, :**] then record.keywords = Hash value
        in [:req, *] | [:opt, *] then record.positionals.append value
        in [:rest, *] then record.positionals.append(*value)
        in [:nokey] then nil
        in [:keyreq, *] | [:key, *] then record.keywords.merge! value if value
        in [:keyrest, *] then record.keywords.merge!(**value) if value
        in [:block, *] then record.block = value
        else fail ArgumentError, "Invalid parameter kind: #{pair.first.inspect}."
      end
    rescue TypeError
      raise TypeError, "#{value.inspect} is an invalid #{pair.first.inspect} value."
    end

    def to_array value
      return unless value

      record.positionals = value.is_a?(Array) ? value : [value]
    end
  end
end
