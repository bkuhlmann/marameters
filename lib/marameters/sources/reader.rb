# frozen_string_literal: true

module Marameters
  module Sources
    # Reads object source code from memory or file (assumes implementation is a one-liner).
    class Reader
      def initialize offset: 1, parser: RubyVM::InstructionSequence, io: File
        @offset = offset
        @parser = parser
        @io = io
        freeze
      end

      def call(object) = build_body_from source_location_of(object)

      private

      attr_reader :offset, :parser, :io

      # :reek:FeatureEnvy
      # rubocop:disable Style/MethodCallWithArgsParentheses
      def build_body_from location
        path, line_start, column_start, line_end, column_end = location
        lines = io.read(path).lines[(line_start - offset)..(line_end - offset)]

        lines[-1] = lines[-1].byteslice(...column_end)
        lines[0] = lines[0].byteslice(column_start..)
        lines.join
      end
      # rubocop:enable Style/MethodCallWithArgsParentheses

      def source_location_of object
        instructions = parser.of object
        path = instructions && instructions.absolute_path

        return [path, *instructions.to_a.dig(4, :code_location)] if path

        fail StandardError, "Unable to find source for: #{object.inspect}."
      end
    end
  end
end
