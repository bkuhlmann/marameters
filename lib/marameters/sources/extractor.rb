# frozen_string_literal: true

module Marameters
  module Sources
    # Extracts the literal source of a Proc's body.
    class Extractor
      PATTERN = /
        proc          # Proc statement.
        \s*           # Optional space.
        \{            # Block open.
        (?<body>.*?)  # Source code body.
        \}            # Block close.
      /x

      def initialize pattern: PATTERN, reader: Reader.new
        @pattern = pattern
        @reader = reader
        @fallback = "nil"
        freeze
      end

      def call function
        reader.call(function).then do |line|
          line.match?(pattern) ? line.match(pattern)[:body].strip : fallback
        end
      end

      private

      attr_reader :pattern, :reader, :fallback
    end
  end
end
