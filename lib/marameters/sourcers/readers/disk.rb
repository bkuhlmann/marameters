# frozen_string_literal: true

module Marameters
  module Sourcers
    module Readers
      # Reads source code from on-disk instruction sequence.
      Disk = lambda do |instructions|
        path = instructions.absolute_path
        line_start, column_start, line_end, column_end = instructions.to_a.dig 4, :code_location
        lines = File.read(path).lines[(line_start - 1)..(line_end - 1)]
        lines[-1] = lines.last.byteslice(...column_end)
        lines[0] = lines.first.byteslice(column_start..)

        lines.join
      end
    end
  end
end
