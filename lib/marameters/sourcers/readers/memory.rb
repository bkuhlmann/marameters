# frozen_string_literal: true

module Marameters
  module Sourcers
    module Readers
      # Reads source code from in-memory instruction sequence.
      Memory = -> instructions { instructions.script_lines.join.chomp }
    end
  end
end
