# frozen_string_literal: true

require "spec_helper"

RSpec.describe Marameters::Signatures::Defaulter do
  subject(:defaulter) { described_class }

  describe "#call" do
    it "answers value as string with custom passthrough" do
      expect(defaulter.call("!Object.new", passthrough: "!")).to eq("Object.new")
    end

    it "answers object as string" do
      expect(defaulter.call("*Object.new")).to eq("Object.new")
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
