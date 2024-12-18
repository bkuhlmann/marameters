# frozen_string_literal: true

module Marameters
  module Signatures
    # Acquires a proc's source code.
    class Sourcer
      PATTERN = /
        proc          # Proc statement.
        \s*           # Optional space.
        \{            # Block open.
        (?<body>.*?)  # Source code body.
        \}            # Block close.
      /x

      def initialize pattern: PATTERN, offset: 1, io: File
        @pattern = pattern
        @offset = offset
        @io = io
        @fallback = "nil"
        freeze
      end

      def call function
        path, line_number = function.source_location

        return fallback unless path && line_number && path.start_with?(File::SEPARATOR)

        io.open(path) { |body| pluck body, line_number }
      end

      private

      attr_reader :pattern, :offset, :io, :fallback

      def pluck body, line_number
        body.each_line
            .with_index
            .find { |_line, index| index + offset == line_number }
            .first
            .then { |line| line.match?(pattern) ? line.match(pattern)[:body].strip : fallback }
      end
    end
  end
end
