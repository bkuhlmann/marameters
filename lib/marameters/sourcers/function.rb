# frozen_string_literal: true

module Marameters
  module Sourcers
    # Obtains the literal source of a function's body.
    class Function
      PATTERN = /
        (?:(?<function>proc|->))?  # Statement.
        \s*                        # Optional space.
        \{                         # Block open.
        (?<body>.*?)               # Source code body.
        \}                         # Block close.
      /x

      def initialize pattern: PATTERN, reader: Readers::Any.new
        @pattern = pattern
        @reader = reader
        freeze
      end

      def call(function) = reader.call(function).then { |line| line.match(pattern)[:body].strip }

      private

      attr_reader :pattern, :reader
    end
  end
end
