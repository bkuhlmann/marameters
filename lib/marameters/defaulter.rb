# frozen_string_literal: true

module Marameters
  # Computes a method parameter's default value.
  Defaulter = lambda do |value|
    case value
      when Proc then fail(ArgumentError, "Avoid using parameters for proc/lambda defaults.")
      when String then value.dump
      when Symbol then value.inspect
      when RubyVM::AbstractSyntaxTree::Node then value.children[2].source
      when nil then "nil"
      else value
    end
  end
end
