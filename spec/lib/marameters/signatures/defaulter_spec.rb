# frozen_string_literal: true

require "spec_helper"

RSpec.describe Marameters::Signatures::Defaulter do
  subject(:defaulter) { described_class }

  describe "#call" do
    let(:name) { "test" }

    it "answers source code when wrapped in a Proc" do
      function = proc { Object.new }
      expect(defaulter.call(function)).to eq("Object.new")
    end

    it "fails when given a lambda" do
      function = -> { "Danger!" }
      expectation = proc { defaulter.call function }

      expect(&expectation).to raise_error(TypeError, "Use procs instead of lambdas for defaults.")
    end

    it "fails when proc uses parameters" do
      function = proc { |no| no }
      expectation = proc { defaulter.call function }

      expect(&expectation).to raise_error(
        ArgumentError,
        "Avoid using parameters for proc defaults."
      )
    end

    it "answers string as string" do
      expect(defaulter.call("test")).to eq(%("test"))
    end

    it "answers symbol as string" do
      expect(defaulter.call(:test)).to eq(":test")
    end

    it "answers nil as string" do
      expect(defaulter.call(nil)).to eq("nil")
    end

    it "answers number as number" do
      expect(defaulter.call(5)).to eq(5)
    end
  end
end
