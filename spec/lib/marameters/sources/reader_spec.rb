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
    it "fails when source can't be loaded" do
      expectation = proc { reader.call 1 }
      expect(&expectation).to raise_error(StandardError, "Unable to load source for: 1.")
    end

    it "answers source from memory" do
      source = %(function = proc { "test" }\n)
      parser = instance_double RubyVM::InstructionSequence, script_lines: [source]
      reader = described_class.new parser: class_double(RubyVM::InstructionSequence, of: parser)
      function = proc { "test" }

      expect(reader.call(function)).to eq(source)
    end

    it "answers source from file" do
      function = proc { "test" }
      expect(reader.call(function)).to eq(%(      function = proc { "test" }\n))
    end

    it "fails with missing source" do
      function = proc { "test" }
      io = class_double File, readable?: false
      expectation = proc { described_class.new(io:).call function }

      expect(&expectation).to raise_error(StandardError, "Unable to load source for: #{function}.")
    end
  end
end
