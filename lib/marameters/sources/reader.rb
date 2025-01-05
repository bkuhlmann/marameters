# frozen_string_literal: true

module Marameters
  module Sources
    # Reads object source code from memory or file (assumes implementation is a one-liner).
    class Reader
      def initialize offset: 1, parser: RubyVM::InstructionSequence, io: File
        warn "`#{self.class}` is deprecated, use `Sourcers::Readers::Any` instead.",
             category: :deprecated

        @offset = offset
        @parser = parser
        @io = io
        freeze
      end

      def call object
        instructions = parser.of object

        fail StandardError, "Unable to load source for: #{object.inspect}." unless instructions

        process object, instructions
      end

      private

      attr_reader :offset, :parser, :io

      def process object, instructions
        lines = instructions.script_lines

        return lines.first if lines
        return extract(*object.source_location) if io.readable? instructions.absolute_path

        fail StandardError, "Unable to load source for: #{object.inspect}."
      end

      def extract(path, line_number) = io.open(path) { |body| pluck body, line_number }

      def pluck body, line_number
        body.each_line
            .with_index
            .find { |_line, index| index + offset == line_number }
            .first
      end
    end
  end
end
