# frozen_string_literal: true

require "spec_helper"

RSpec.describe Marameters::Sourcers::Readers::Disk do
  subject(:sourcer) { described_class }

  describe "#call" do
    it "answers function source" do
      function = proc { "test" }
      instructions = RubyVM::InstructionSequence.of function

      expect(sourcer.call(instructions)).to eq(%({ "test" }))
    end

    it "answers method source" do
      object = Module.new do
        def self.as_string text: :text
          String text
        end
      end

      instructions = RubyVM::InstructionSequence.of object.method(:as_string)

      expect(sourcer.call(instructions)).to eq(
        "def self.as_string text: :text\n          String text\n        end"
      )
    end
  end
end
