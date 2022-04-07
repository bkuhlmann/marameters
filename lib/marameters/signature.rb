# frozen_string_literal: true

module Marameters
  # Produces a method signature for given parameters.
  class Signature
    def initialize parameters, builder: Builder.new
      @parameters = parameters
      @builder = builder
    end

    def to_s = build.join ", "

    alias to_str to_s

    private

    attr_reader :parameters, :builder

    def build
      parameters.reduce [] do |signature, (kind, (name, default))|
        signature << builder.call(kind, name, default:)
      end
    end
  end
end
