# frozen_string_literal: true

module Marameters
  module Signatures
    # Computes a method parameter's default value.
    Defaulter = lambda do |value, extractor: Sourcers::Function.new|
      case value
        when Proc
          fail TypeError, "Use procs instead of lambdas for defaults." if value.lambda?
          fail ArgumentError, "Avoid using parameters for proc defaults." if value.arity.nonzero?

          extractor.call value
        when Regexp, Symbol then value.inspect
        when String then value.dump
        when nil then "nil"
        else value
      end
    end
  end
end
