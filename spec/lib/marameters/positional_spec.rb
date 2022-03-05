# frozen_string_literal: true

require "spec_helper"

RSpec.describe Marameters::Positional do
  subject(:positional) { described_class.new parameters }

  include_context "with parameters"

  describe "#empty?" do
    context "when parameters exist" do
      let(:parameters) { comprehensive }

      it "answers false" do
        expect(positional.empty?).to be(false)
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers false" do
        expect(positional.empty?).to be(true)
      end
    end
  end

  describe "#kinds" do
    context "when parameters exist" do
      let(:parameters) { comprehensive }

      it "answers kinds" do
        expect(positional.kinds).to eq(%i[req opt])
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers empty array" do
        expect(positional.kinds).to be_empty
      end
    end
  end

  describe "#names" do
    context "when parameters exist" do
      let(:parameters) { comprehensive }

      it "answers names" do
        expect(positional.names).to eq(%i[one two])
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers empty array" do
        expect(positional.names).to be_empty
      end
    end
  end
end
