# frozen_string_literal: true

require "spec_helper"

RSpec.describe Marameters::Keyword do
  subject(:keyword) { described_class.new parameters }

  include_context "with parameters"

  describe "#empty?" do
    context "when parameters exist" do
      let(:parameters) { comprehensive }

      it "answers false" do
        expect(keyword.empty?).to be(false)
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers false" do
        expect(keyword.empty?).to be(true)
      end
    end
  end

  describe "#kinds" do
    context "when parameters exist" do
      let(:parameters) { comprehensive }

      it "answers kinds" do
        expect(keyword.kinds).to eq(%i[keyreq key])
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers empty array" do
        expect(keyword.kinds).to be_empty
      end
    end
  end

  describe "#name?" do
    context "when parameters exist" do
      let(:parameters) { comprehensive }

      it "answers true with match" do
        expect(keyword.name?(:four)).to be(true)
      end

      it "answers false without match" do
        expect(keyword.name?(:unknown)).to be(false)
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers false" do
        expect(keyword.name?(:unknown)).to be(false)
      end
    end
  end

  describe "#names" do
    context "when parameters exist" do
      let(:parameters) { comprehensive }

      it "answers names" do
        expect(keyword.names).to eq(%i[four five])
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers empty array" do
        expect(keyword.names).to be_empty
      end
    end
  end
end
