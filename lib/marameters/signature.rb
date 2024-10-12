# frozen_string_literal: true

module Marameters
  # Builds a method's parameter signature.
  class Signature
    def self.of super_params,
                sub_params,
                aids: {anonymizer: Signatures::Anonymizer, reducer: Signatures::Reducer}

      aids.fetch(:anonymizer)
          .call(*super_params)
          .union(sub_params)
          .then { |union| aids.fetch(:reducer).call union }
          .sort_by! { |(kind, *)| KINDS.index kind }
          .then { |forwards| new(*forwards) }
    end

    def initialize *parameters, parser: RubyVM::AbstractSyntaxTree, builder: Signatures::Builder.new
      @parameters = parameters.all?(Array) ? parameters : [parameters]
      @parser = parser
      @builder = builder
    end

    def for_super = build_for_super.join ", "

    def to_s = parameters == [[:all]] ? "..." : build.join(", ")

    alias to_str to_s

    private

    attr_reader :parameters, :parser, :builder

    def build_for_super positionals = CATEGORIES.positionals
      parameters.filter_map do |kind, name|
        case kind
          when *positionals then name
          when :rest then "*"
          when :keyrest then "**"
          when :block then "&"
        end
      end
    end

    def build
      parameters.reduce [] do |signature, (kind, name, default)|
        default = parser.of(default) if default.is_a?(Proc) && default.arity.zero?
        signature << builder.call(kind, name, default:)
      end
    end
  end
end
