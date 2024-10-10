# frozen_string_literal: true

module Marameters
  module Signatures
    # Computes a method parameter's default value.
    Defaulter = lambda do |value, extractor: Sources::Extractor.new|
      case value
        when Proc
          fail TypeError, "Use procs instead of lambdas for defaults." if value.lambda?
          fail ArgumentError, "Avoid using parameters for proc defaults." if value.arity.nonzero?

          extractor.call value
        when String then value.dump
        when Symbol then value.inspect
        when nil then "nil"
        else value
      end
    end
  end
end
