# frozen_string_literal: true

require "spec_helper"

RSpec.describe Marameters::Sourcers::Function do
  subject(:extractor) { described_class.new }

  describe "#initialize" do
    it "is frozen by default" do
      expect(extractor.frozen?).to be(true)
    end
  end

  describe "#call" do
    it "answers body when a proc" do
      function = proc { :test }
      expect(extractor.call(function)).to eq(":test")
    end

    it "answers nil when a lambda" do
      function = -> { :test }
      expect(extractor.call(function)).to eq(":test")
    end

    it "fails when source can't be found" do
      function = Object.method :new
      expectation = proc { extractor.call function }

      expect(&expectation).to raise_error(StandardError, /unable to load source/i)
    end
  end
end
