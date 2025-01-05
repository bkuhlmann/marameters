# frozen_string_literal: true

require "spec_helper"

RSpec.describe Marameters::Sourcers::Readers::Memory do
  subject(:sourcer) { described_class }

  describe "#call" do
    it "answers function source" do
      lines = ["function = proc { :test }\n", ""]
      instructions = instance_double RubyVM::InstructionSequence, script_lines: lines

      expect(sourcer.call(instructions)).to eq("function = proc { :test }")
    end

    it "answers method source" do
      lines = [
        "def say text: :text\n",
        "  puts text\n",
        "end\n",
        ""
      ]

      instructions = instance_double RubyVM::InstructionSequence, script_lines: lines

      expect(sourcer.call(instructions)).to eq("def say text: :text\n  puts text\nend")
    end
  end
end
