# frozen_string_literal: true

module Marameters
  # Builds a method's parameter signature.
  class Signature
    def initialize *parameters, parser: RubyVM::AbstractSyntaxTree, builder: Builder.new
      @parameters = parameters.all?(Array) ? parameters : [parameters]
      @parser = parser
      @builder = builder
    end

    def to_s = build.join ", "

    alias to_str to_s

    private

    attr_reader :parameters, :parser, :builder

    def build
      parameters.reduce [] do |signature, (kind, name, default)|
        default = parser.of(default) if default.is_a?(Proc) && default.arity.zero?
        signature << builder.call(kind, name, default:)
      end
    end
  end
end
