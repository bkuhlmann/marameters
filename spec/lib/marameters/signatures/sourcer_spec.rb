# frozen_string_literal: true

require "spec_helper"

RSpec.describe Marameters::Signatures::Sourcer do
  subject(:sourcer) { described_class.new }

  describe "#initialize" do
    it "is frozen by default" do
      expect(sourcer.frozen?).to be(true)
    end
  end

  describe "#call" do
    it "answers source code when a proc" do
      function = proc { "test" }
      expect(sourcer.call(function)).to eq(%("test"))
    end

    it "answers nil when a lambda" do
      function = -> { "test" }
      expect(sourcer.call(function)).to eq("nil")
    end

    it "answers nil when path starts with parentheses" do
      function = Object.method :new
      allow(function).to receive(:source_location).and_return ["(irb)", 1]

      expect(sourcer.call(function)).to eq("nil")
    end

    it "answers nil when source can't be found" do
      function = Object.method :new
      expect(sourcer.call(function)).to eq("nil")
    end
  end
end
