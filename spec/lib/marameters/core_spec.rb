# frozen_string_literal: true

require "spec_helper"

RSpec.describe Marameters::Core do
  subject(:core) { described_class.new parameters }

  include_context "with parameters"

  describe ".of" do
    it "answers parameters with no inheritance" do
      parameters = described_class.of(test_module, :trial).flat_map(&:to_a)
      expect(parameters).to eq(comprehensive_proof)
    end

    it "answers parameters defined via multiple inheritance" do
      module_a = Module.new { def initialize(one) = [super, one] }
      module_b = Module.new { def initialize(two:) = [super, two] }
      klass = Class.new.include module_a, module_b

      parameters = described_class.of(klass, :initialize).flat_map(&:to_a)

      expect(parameters).to eq([%i[req one], %i[keyreq two]])
    end

    it "answers empty array with no parameters" do
      parameters = described_class.of(BasicObject, :initialize).flat_map(&:to_a)
      expect(parameters).to be_empty
    end

    it "answers empty array when instance method doesn't exist" do
      expect(described_class.of(BasicObject, :bogus).to_a).to be_empty
    end
  end

  describe "#empty?" do
    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers true" do
        expect(core.empty?).to be(true)
      end
    end

    context "when parameters exist" do
      let(:parameters) { comprehensive }

      it "answers false" do
        expect(core.empty?).to be(false)
      end
    end
  end

  describe "#keyword?" do
    context "when parameters exist" do
      let(:parameters) { comprehensive }

      it "answers true when matched" do
        expect(core.keyword?(:four)).to be(true)
      end

      it "answers false when unmatched" do
        expect(core.keyword?(:bogus)).to be(false)
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers false" do
        expect(core.keyword?(:one)).to be(false)
      end
    end
  end

  describe "#keywords" do
    context "when parameters exist" do
      let(:parameters) { comprehensive }

      it "answers empty array" do
        expect(core.keywords).to eq(%i[four five])
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers empty array" do
        expect(core.keywords).to be_empty
      end
    end
  end

  describe "#kinds" do
    context "when parameters exist" do
      let(:parameters) { comprehensive }

      it "answers array" do
        expect(core.kinds).to eq(%i[req opt keyreq key rest keyrest])
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers empty array" do
        expect(core.kinds).to be_empty
      end
    end
  end

  describe "#named_single_splat_only?" do
    context "when parameters exist" do
      let :parameters do
        Module.new { def trial(*one) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers false" do
        expect(core.named_single_splat_only?).to be(true)
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers false" do
        expect(core.named_single_splat_only?).to be(false)
      end
    end
  end

  describe "#names" do
    context "when parameters exist" do
      let(:parameters) { comprehensive }

      it "answers array" do
        expect(core.names).to eq(%i[one two four five three six])
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers empty array" do
        expect(core.names).to be_empty
      end
    end
  end

  describe "#positional?" do
    context "when parameters exist" do
      let(:parameters) { comprehensive }

      it "answers true" do
        expect(core.positional?).to be(true)
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers false" do
        expect(core.positional?).to be(false)
      end
    end
  end

  describe "#positionals" do
    context "when parameters exist" do
      let(:parameters) { comprehensive }

      it "answers array of names" do
        expect(core.positionals).to eq(%i[one two])
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers empty array" do
        expect(core.positionals).to be_empty
      end
    end
  end

  describe "#slice" do
    let(:parameters) { comprehensive }

    it "answers method arguments and excludes non-method arguments" do
      expectation = core.slice({a: 1, four: 4}, keys: [:a])
      expect(expectation).to eq({four: 4})
    end

    it "answers originals pairs when keys don't match" do
      expectation = core.slice({a: 1, b: 2}, keys: %i[x z])
      expect(expectation).to eq(a: 1, b: 2)
    end

    it "answers original pairs when keys match method arguments" do
      expectation = core.slice({a: 1, four: 4}, keys: [:four])
      expect(expectation).to eq({a: 1, four: 4})
    end
  end

  describe "#to_a" do
    context "when parameters exist" do
      let(:parameters) { comprehensive }

      it "answers array of names" do
        expect(core.to_a).to eq(comprehensive_proof)
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers array of names" do
        expect(core.to_a).to be_empty
      end
    end
  end

  describe "#unnamed_splats_only?" do
    context "when parameters exist" do
      let :parameters do
        Module.new { def trial(*, **) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers empty array" do
        expect(core.unnamed_splats_only?).to be(true)
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers false" do
        expect(core.unnamed_splats_only?).to be(false)
      end
    end
  end
end
