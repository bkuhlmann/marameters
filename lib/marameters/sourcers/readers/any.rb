# frozen_string_literal: true

module Marameters
  module Sourcers
    module Readers
      # Reads source code of callable from disk or memory.
      class Any
        def initialize parser: RubyVM::InstructionSequence, disk: Disk, memory: Memory
          @parser = parser
          @disk = disk
          @memory = memory
          freeze
        end

        def call callable
          instructions = parser.of callable

          fail StandardError, "Unable to load source for: #{callable.inspect}." unless instructions

          instructions.absolute_path ? disk.call(instructions) : memory.call(instructions)
        end

        private

        attr_reader :parser, :disk, :memory
      end
    end
  end
end
