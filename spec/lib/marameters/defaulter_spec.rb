# frozen_string_literal: true

require "spec_helper"

RSpec.describe Marameters::Defaulter do
  subject(:defaulter) { described_class.new value }

  describe ".call" do
    it "answers value as string" do
      expect(described_class.call(:test)).to eq(":test")
    end
  end

  describe "#call" do
    it "answers value as string with custom passthrough" do
      expect(described_class.new("!Object.new", passthrough: "!").call).to eq("Object.new")
    end

    context "with nil" do
      let(:value) { nil }

      it "answers nil as string" do
        expect(defaulter.call).to eq("nil")
      end
    end

    context "with passthrough" do
      let(:value) { "*Object.new" }

      it "answers object as string" do
        expect(defaulter.call).to eq("Object.new")
      end
    end

    context "with string" do
      let(:value) { "test" }

      it "answers string as string" do
        expect(defaulter.call).to eq(%("test"))
      end
    end

    context "with symbol" do
      let(:value) { :test }

      it "answers symbol as string" do
        expect(defaulter.call).to eq(":test")
      end
    end
  end
end
