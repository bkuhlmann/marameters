# frozen_string_literal: true

require "spec_helper"

RSpec.describe Marameters::Defaulter do
  subject(:defaulter) { described_class }

  describe "#call" do
    it "fails when given a default" do
      function = -> no { no }
      expectation = proc { defaulter.call function }

      expect(&expectation).to raise_error(
        ArgumentError,
        "Avoid using parameters for proc/lambda defaults."
      )
    end

    it "answers string as string" do
      expect(defaulter.call("test")).to eq(%("test"))
    end

    it "answers symbol as string" do
      expect(defaulter.call(:test)).to eq(":test")
    end

    it "answers VM abstract syntax tree node (proc) as string" do
      function = proc { Object.new }
      node = RubyVM::AbstractSyntaxTree.of function

      expect(defaulter.call(node)).to eq("Object.new")
    end

    it "answers VM abstract syntax tree node (lambda) as string" do
      function = -> { Object.new }
      node = RubyVM::AbstractSyntaxTree.of function

      expect(defaulter.call(node)).to eq("Object.new")
    end

    it "answers nil as string" do
      expect(defaulter.call(nil)).to eq("nil")
    end

    it "answers number as number" do
      expect(defaulter.call(5)).to eq(5)
    end
  end
end
