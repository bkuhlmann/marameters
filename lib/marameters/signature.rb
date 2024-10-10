# frozen_string_literal: true

module Marameters
  # Builds a method's parameter signature.
  class Signature
    def initialize marameter_builder: Builder.new, **parameters
      @marameter_builder = marameter_builder
      @parameters = parameters
    end

    def to_s = build.join ", "

    alias to_str to_s

    private

    attr_reader :marameter_builder, :parameters

    def build
      parameters.reduce [] do |signature, (kind, (name, default))|
        signature << marameter_builder.call(kind, name, default:)
      end
    end
  end
end
