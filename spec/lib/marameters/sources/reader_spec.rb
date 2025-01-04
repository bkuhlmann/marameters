# frozen_string_literal: true

require "spec_helper"

RSpec.describe Marameters::Sources::Reader do
  subject(:reader) { described_class.new }

  describe "#initialize" do
    it "is frozen" do
      expect(reader.frozen?).to be(true)
    end
  end

  describe "#call" do
    it "answers source when found" do
      function = proc { "test" }
      expect(reader.call(function)).to eq(%({ "test" }))
    end

    it "fails when source can't be found" do
      parser = class_double RubyVM::InstructionSequence,
                            of: instance_double(RubyVM::InstructionSequence, absolute_path: nil)
      reader = described_class.new(parser:)
      function = proc { "test" }
      expectation = proc { reader.call function }

      expect(&expectation).to raise_error(StandardError, "Unable to find source for: #{function}.")
    end

    it "fails when object is a primitive" do
      expectation = proc { reader.call 1 }
      expect(&expectation).to raise_error(StandardError, "Unable to find source for: 1.")
    end
  end
end
