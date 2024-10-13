# frozen_string_literal: true

require "spec_helper"

RSpec.describe Marameters::Probe do
  subject(:probe) { described_class.new parameters }

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

  describe "#block" do
    context "with only block" do
      let :parameters do
        Module.new { def trial(&) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers ampersand" do
        expect(probe.block).to eq(:&)
      end
    end

    context "with only named block" do
      let(:parameters) { comprehensive }

      it "answers name" do
        expect(probe.block).to eq(:seven)
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers nil" do
        expect(probe.block).to be(nil)
      end
    end
  end

  describe "#block?" do
    context "when block exists" do
      let(:parameters) { comprehensive }

      it "answers true" do
        expect(probe.block?).to be(true)
      end
    end

    context "when block doesn't exist" do
      let(:parameters) { none }

      it "answers false" do
        expect(probe.block?).to be(false)
      end
    end
  end

  describe "#empty?" do
    context "when parameters exist" do
      let(:parameters) { comprehensive }

      it "answers false" do
        expect(probe.empty?).to be(false)
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers false" do
        expect(probe.empty?).to be(true)
      end
    end
  end

  describe "#keyword_slice" do
    let(:parameters) { comprehensive }

    it "answers method arguments and excludes non-method arguments" do
      expectation = probe.keyword_slice({a: 1, four: 4}, keys: [:a])
      expect(expectation).to eq({four: 4})
    end

    it "answers originals pairs when keys don't match" do
      expectation = probe.keyword_slice({a: 1, b: 2}, keys: %i[x z])
      expect(expectation).to eq(a: 1, b: 2)
    end

    it "answers original pairs when keys match method arguments" do
      expectation = probe.keyword_slice({a: 1, four: 4}, keys: [:four])
      expect(expectation).to eq({a: 1, four: 4})
    end
  end

  describe "#keywords" do
    context "when parameters exist" do
      let(:parameters) { comprehensive }

      it "answers array of names" do
        expect(probe.keywords).to eq(%i[four five])
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers empty array" do
        expect(probe.keywords).to eq([])
      end
    end
  end

  describe "#keywords?" do
    context "when parameters exist" do
      let(:parameters) { comprehensive }

      it "answers true" do
        expect(probe.keywords?).to be(true)
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers false" do
        expect(probe.keywords?).to be(false)
      end
    end
  end

  describe "#keywords_for" do
    let(:parameters) { comprehensive }

    it "answers method arguments and excludes non-method arguments" do
      expectation = probe.keywords_for :a, a: 1, four: 4
      expect(expectation).to eq({four: 4})
    end

    it "answers originals pairs when keys don't match" do
      expectation = probe.keywords_for :x, :z, a: 1, b: 2
      expect(expectation).to eq(a: 1, b: 2)
    end

    it "answers original pairs when keys match method arguments" do
      expectation = probe.keywords_for :four, a: 1, four: 4
      expect(expectation).to eq({a: 1, four: 4})
    end
  end

  describe "#kind?" do
    context "when parameters exist" do
      let(:parameters) { comprehensive }

      it "answers true with match" do
        expect(probe.kind?(:req)).to be(true)
      end

      it "answers false without match" do
        expect(probe.kind?(:unknown)).to be(false)
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers false" do
        expect(probe.kind?(:unknown)).to be(false)
      end
    end
  end

  describe "#kinds" do
    context "when parameters exist" do
      let(:parameters) { comprehensive }

      it "answers kinds" do
        expect(probe.kinds).to eq(%i[req opt rest keyreq key keyrest block])
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers empty array" do
        expect(probe.kinds).to be_empty
      end
    end
  end

  describe "#name?" do
    context "when parameters exist" do
      let(:parameters) { comprehensive }

      it "answers true with match" do
        expect(probe.name?(:one)).to be(true)
      end

      it "answers false without match" do
        expect(probe.name?(:unknown)).to be(false)
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers false" do
        expect(probe.name?(:unknown)).to be(false)
      end
    end
  end

  describe "#names" do
    context "when parameters exist" do
      let(:parameters) { comprehensive }

      it "answers names" do
        expect(probe.names).to eq(%i[one two three four five six seven])
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers empty array" do
        expect(probe.names).to eq([])
      end
    end
  end

  describe "#only_bare_splats?" do
    context "with only single bare splat" do
      let(:parameters) { Data.method(:define).parameters }

      it "answers true" do
        expect(probe.only_bare_splats?).to be(true)
      end
    end

    context "with only single splat" do
      let :parameters do
        Module.new { def trial(*) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers true" do
        expect(probe.only_bare_splats?).to be(true)
      end
    end

    context "with only single named splat" do
      let :parameters do
        Module.new { def trial(*one) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers false" do
        expect(probe.only_bare_splats?).to be(false)
      end
    end

    context "with only double splat" do
      let :parameters do
        Module.new { def trial(**) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers true" do
        expect(probe.only_bare_splats?).to be(true)
      end
    end

    context "with only double named splat" do
      let :parameters do
        Module.new { def trial(**one) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers false" do
        expect(probe.only_bare_splats?).to be(false)
      end
    end

    context "with only single and double bare splats" do
      let :parameters do
        Module.new { def trial(*, **) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers true" do
        expect(probe.only_bare_splats?).to be(true)
      end
    end

    context "with only single and double named splats" do
      let :parameters do
        Module.new { def trial(*one, **two) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers false" do
        expect(probe.only_bare_splats?).to be(false)
      end
    end

    context "with no parameterss" do
      let(:parameters) { none }

      it "answers false" do
        expect(probe.only_bare_splats?).to be(false)
      end
    end
  end

  describe "#only_double_splats?" do
    context "with only single splat" do
      let :parameters do
        Module.new { def trial(*) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers false" do
        expect(probe.only_double_splats?).to be(false)
      end
    end

    context "with only double splat" do
      let :parameters do
        Module.new { def trial(**) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers true" do
        expect(probe.only_double_splats?).to be(true)
      end
    end

    context "with only double named splat" do
      let :parameters do
        Module.new { def trial(**one) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers true" do
        expect(probe.only_double_splats?).to be(true)
      end
    end

    context "with only single and double splats" do
      let :parameters do
        Module.new { def trial(*, **) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers false" do
        expect(probe.only_double_splats?).to be(false)
      end
    end

    context "with no parameterss" do
      let(:parameters) { none }

      it "answers false" do
        expect(probe.only_double_splats?).to be(false)
      end
    end
  end

  describe "#only_single_splats?" do
    context "with only single bare splat" do
      let(:parameters) { Data.method(:define).parameters }

      it "answers true" do
        expect(probe.only_single_splats?).to be(true)
      end
    end

    context "with only single splat" do
      let :parameters do
        Module.new { def trial(*) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers true" do
        expect(probe.only_single_splats?).to be(true)
      end
    end

    context "with only single named splat" do
      let :parameters do
        Module.new { def trial(*one) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers true" do
        expect(probe.only_single_splats?).to be(true)
      end
    end

    context "with only double splat" do
      let :parameters do
        Module.new { def trial(**) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers false" do
        expect(probe.only_single_splats?).to be(false)
      end
    end

    context "with only single and double splats" do
      let :parameters do
        Module.new { def trial(*, **) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers false" do
        expect(probe.only_single_splats?).to be(false)
      end
    end

    context "with no parameterss" do
      let(:parameters) { none }

      it "answers false" do
        expect(probe.only_single_splats?).to be(false)
      end
    end
  end

  describe "#positionals" do
    context "when parameters exist" do
      let(:parameters) { comprehensive }

      it "answers array of names" do
        expect(probe.positionals).to eq(%i[one two])
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers empty array" do
        expect(probe.positionals).to eq([])
      end
    end
  end

  describe "#positionals?" do
    context "when parameters exist" do
      let(:parameters) { comprehensive }

      it "answers true" do
        expect(probe.positionals?).to be(true)
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers false" do
        expect(probe.positionals?).to be(false)
      end
    end
  end

  describe "#splats" do
    context "with only bare splats" do
      let :parameters do
        Module.new { def trial(*, **) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers splats" do
        expect(probe.splats).to eq(%i[* **])
      end
    end

    context "when named parameters exist" do
      let(:parameters) { comprehensive }

      it "answers array of names" do
        expect(probe.splats).to eq(%i[three six])
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers empty array" do
        expect(probe.splats).to eq([])
      end
    end
  end

  describe "#splats?" do
    context "when parameters exist" do
      let(:parameters) { comprehensive }

      it "answers true" do
        expect(probe.splats?).to be(true)
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers false" do
        expect(probe.splats?).to be(false)
      end
    end
  end

  describe "#to_a" do
    context "when parameters exist" do
      let(:parameters) { comprehensive }

      it "answers array" do
        expect(probe.to_a).to eq(comprehensive_proof)
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers empty array" do
        expect(probe.to_a).to eq([])
      end
    end
  end
end
