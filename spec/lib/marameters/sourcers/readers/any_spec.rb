# frozen_string_literal: true

require "spec_helper"

RSpec.describe Marameters::Sourcers::Readers::Any do
  subject(:sourcer) { described_class.new }

  describe "#initialize" do
    it "is frozen" do
      expect(sourcer.frozen?).to be(true)
    end
  end

  describe "#call" do
    it "answers source from memory" do
      function = proc { :test }
      parser = class_double RubyVM::InstructionSequence,
                            of: instance_double(
                              RubyVM::InstructionSequence,
                              absolute_path: nil,
                              script_lines: ["function = proc { :test }\n", ""]
                            )
      sourcer = described_class.new(parser:)

      expect(sourcer.call(function)).to eq("function = proc { :test }")
    end

    it "answers source from disk" do
      function = proc { "test" }
      expect(sourcer.call(function)).to eq(%({ "test" }))
    end

    it "fails when source can't be obtained" do
      object = Object.new
      expectation = proc { sourcer.call object }

      expect(&expectation).to raise_error(StandardError, /Unable to load source for: #{object}\./)
    end
  end
end
