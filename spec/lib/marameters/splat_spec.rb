# frozen_string_literal: true

require "spec_helper"

RSpec.describe Marameters::Splat do
  subject(:passthrough) { described_class.new parameters }

  include_context "with parameters"

  describe "#empty?" do
    context "when parameters exist" do
      let(:parameters) { comprehensive }

      it "answers false" do
        expect(passthrough.empty?).to be(false)
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers false" do
        expect(passthrough.empty?).to be(true)
      end
    end
  end

  describe "#kinds" do
    context "when parameters exist" do
      let(:parameters) { comprehensive }

      it "answers kinds" do
        expect(passthrough.kinds).to eq(%i[rest keyrest])
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers empty array" do
        expect(passthrough.kinds).to be_empty
      end
    end
  end

  describe "#names" do
    context "when parameters exist" do
      let(:parameters) { comprehensive }

      it "answers names" do
        expect(passthrough.names).to eq(%i[three six])
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers empty array" do
        expect(passthrough.names).to be_empty
      end
    end
  end

  describe "#named_double_only?" do
    context "with only single unnamed" do
      let :parameters do
        Module.new { def trial(*one) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers false" do
        expect(passthrough.named_double_only?).to be(false)
      end
    end

    context "with only double unnamed" do
      let :parameters do
        Module.new { def trial(**) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers true" do
        expect(passthrough.named_double_only?).to be(true)
      end
    end

    context "with only double named" do
      let :parameters do
        Module.new { def trial(**one) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers true" do
        expect(passthrough.named_double_only?).to be(true)
      end
    end

    context "with no parameters" do
      let(:parameters) { none }

      it "answers false" do
        expect(passthrough.named_double_only?).to be(false)
      end
    end
  end

  describe "#named_single_only?" do
    context "with only single unnamed" do
      let :parameters do
        Module.new { def trial(*one) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers true" do
        expect(passthrough.named_single_only?).to be(true)
      end
    end

    context "with only double unnamed" do
      let :parameters do
        Module.new { def trial(**one) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers false" do
        expect(passthrough.named_single_only?).to be(false)
      end
    end

    context "with no parameterss" do
      let(:parameters) { none }

      it "answers false when unnamed doesn't exist?" do
        expect(passthrough.named_single_only?).to be(false)
      end
    end
  end

  describe "#unnamed_only?" do
    context "with only single unnamed" do
      let :parameters do
        Module.new { def trial(*) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers true" do
        expect(passthrough.unnamed_only?).to be(true)
      end
    end

    context "with only single named" do
      let :parameters do
        Module.new { def trial(*one) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers false" do
        expect(passthrough.unnamed_only?).to be(false)
      end
    end

    context "with only double unnamed" do
      let :parameters do
        Module.new { def trial(**) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers true" do
        expect(passthrough.unnamed_only?).to be(true)
      end
    end

    context "with only double named" do
      let :parameters do
        Module.new { def trial(**one) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers false" do
        expect(passthrough.unnamed_only?).to be(false)
      end
    end

    context "with single and double unnamed only" do
      let :parameters do
        Module.new { def trial(*, **) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers true" do
        expect(passthrough.unnamed_only?).to be(true)
      end
    end

    context "with single and double named only" do
      let :parameters do
        Module.new { def trial(*one, **two) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers false" do
        expect(passthrough.unnamed_only?).to be(false)
      end
    end

    context "with no parameterss" do
      let(:parameters) { none }

      it "answers false when unnamed doesn't exist?" do
        expect(passthrough.unnamed_only?).to be(false)
      end
    end
  end
end
