# frozen_string_literal: true

module Marameters
  module Sources
    # Extracts the literal source of a Proc's body.
    class Extractor
      PATTERN = /
        \{            # Block open.
        (?<body>.*?)  # Source code body.
        \}            # Block close.
      /x

      def initialize pattern: PATTERN, reader: Reader.new
        @pattern = pattern
        @reader = reader
        freeze
      end

      def call function
        reader.call(function).then { |line| line.match(pattern)[:body].strip }
      end

      private

      attr_reader :pattern, :reader
    end
  end
end
