# frozen_string_literal: true

module Marameters
  # Builds a method's parameter signature.
  class Signature
    CONTAINER = {
      parser: RubyVM::AbstractSyntaxTree,
      builder: Signatures::Builder.new,
      merger: Signatures::Merger.new,
      forwarder: Signatures::Forwarder
    }.freeze

    def initialize *parameters, container: CONTAINER
      @parameters = parameters.all?(Array) ? parameters : [parameters]

      container.each { |key, value| instance_variable_set :"@#{key}", value }
    end

    def super_for ancestor
      merger.call(ancestor, parameters)
            .then { |result| result - parameters }
            .filter_map { |kind, name| forwarder.call kind, name }
            .join ", "
    end

    def to_s = parameters == [[:all]] ? "..." : build.join(", ")

    alias to_str to_s

    private

    attr_reader :parameters, :parser, :builder, :merger, :forwarder

    def build
      parameters.reduce [] do |signature, (kind, name, default)|
        default = parser.of(default) if default.is_a?(Proc) && default.arity.zero?
        signature << builder.call(kind, name, default:)
      end
    end
  end
end
