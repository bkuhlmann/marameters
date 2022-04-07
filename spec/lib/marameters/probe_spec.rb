# frozen_string_literal: true

require "spec_helper"

RSpec.describe Marameters::Probe do
  subject(:analyzer) { described_class.new parameters }

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
    context "with only bare block" do
      let :parameters do
        Module.new { def trial(&) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers ampersand" do
        expect(analyzer.block).to eq(:&)
      end
    end

    context "with only named block" do
      let(:parameters) { comprehensive }

      it "answers name" do
        expect(analyzer.block).to eq(:seven)
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers nil" do
        expect(analyzer.block).to be_nil
      end
    end
  end

  describe "#block?" do
    context "when block exists" do
      let(:parameters) { comprehensive }

      it "answers true" do
        expect(analyzer.block?).to be(true)
      end
    end

    context "when block doesn't exist" do
      let(:parameters) { none }

      it "answers false" do
        expect(analyzer.block?).to be(false)
      end
    end
  end

  describe "#empty?" do
    context "when parameters exist" do
      let(:parameters) { comprehensive }

      it "answers false" do
        expect(analyzer.empty?).to be(false)
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers false" do
        expect(analyzer.empty?).to be(true)
      end
    end
  end

  describe "#keyword_slice" do
    let(:parameters) { comprehensive }

    it "answers method arguments and excludes non-method arguments" do
      expectation = analyzer.keyword_slice({a: 1, four: 4}, keys: [:a])
      expect(expectation).to eq({four: 4})
    end

    it "answers originals pairs when keys don't match" do
      expectation = analyzer.keyword_slice({a: 1, b: 2}, keys: %i[x z])
      expect(expectation).to eq(a: 1, b: 2)
    end

    it "answers original pairs when keys match method arguments" do
      expectation = analyzer.keyword_slice({a: 1, four: 4}, keys: [:four])
      expect(expectation).to eq({a: 1, four: 4})
    end
  end

  describe "#keywords" do
    context "when parameters exist" do
      let(:parameters) { comprehensive }

      it "answers array of names" do
        expect(analyzer.keywords).to eq(%i[four five])
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers empty array" do
        expect(analyzer.keywords).to eq([])
      end
    end
  end

  describe "#keywords?" do
    context "when parameters exist" do
      let(:parameters) { comprehensive }

      it "answers true" do
        expect(analyzer.keywords?).to be(true)
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers false" do
        expect(analyzer.keywords?).to be(false)
      end
    end
  end

  describe "#kind?" do
    context "when parameters exist" do
      let(:parameters) { comprehensive }

      it "answers true with match" do
        expect(analyzer.kind?(:req)).to be(true)
      end

      it "answers false without match" do
        expect(analyzer.kind?(:unknown)).to be(false)
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers false" do
        expect(analyzer.kind?(:unknown)).to be(false)
      end
    end
  end

  describe "#kinds" do
    context "when parameters exist" do
      let(:parameters) { comprehensive }

      it "answers kinds" do
        expect(analyzer.kinds).to eq(%i[req opt rest keyreq key keyrest block])
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers empty array" do
        expect(analyzer.kinds).to be_empty
      end
    end
  end

  describe "#name?" do
    context "when parameters exist" do
      let(:parameters) { comprehensive }

      it "answers true with match" do
        expect(analyzer.name?(:one)).to be(true)
      end

      it "answers false without match" do
        expect(analyzer.name?(:unknown)).to be(false)
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers false" do
        expect(analyzer.name?(:unknown)).to be(false)
      end
    end
  end

  describe "#names" do
    context "when parameters exist" do
      let(:parameters) { comprehensive }

      it "answers names" do
        expect(analyzer.names).to eq(%i[one two three four five six seven])
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers empty array" do
        expect(analyzer.names).to eq([])
      end
    end
  end

  describe "#only_bare_splats?" do
    context "with only single bare splat" do
      let :parameters do
        Module.new { def trial(*) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers true" do
        expect(analyzer.only_bare_splats?).to be(true)
      end
    end

    context "with only single named splat" do
      let :parameters do
        Module.new { def trial(*one) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers false" do
        expect(analyzer.only_bare_splats?).to be(false)
      end
    end

    context "with only double bare splat" do
      let :parameters do
        Module.new { def trial(**) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers true" do
        expect(analyzer.only_bare_splats?).to be(true)
      end
    end

    context "with only double named splat" do
      let :parameters do
        Module.new { def trial(**one) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers false" do
        expect(analyzer.only_bare_splats?).to be(false)
      end
    end

    context "with only single and double bare splats" do
      let :parameters do
        Module.new { def trial(*, **) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers true" do
        expect(analyzer.only_bare_splats?).to be(true)
      end
    end

    context "with only single and double named splats" do
      let :parameters do
        Module.new { def trial(*one, **two) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers false" do
        expect(analyzer.only_bare_splats?).to be(false)
      end
    end

    context "with no parameterss" do
      let(:parameters) { none }

      it "answers false" do
        expect(analyzer.only_bare_splats?).to be(false)
      end
    end
  end

  describe "#only_double_splats?" do
    context "with only single bare splat" do
      let :parameters do
        Module.new { def trial(*) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers false" do
        expect(analyzer.only_double_splats?).to be(false)
      end
    end

    context "with only single named splat" do
      let :parameters do
        Module.new { def trial(*one) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers false" do
        expect(analyzer.only_double_splats?).to be(false)
      end
    end

    context "with only double bare splat" do
      let :parameters do
        Module.new { def trial(**) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers true" do
        expect(analyzer.only_double_splats?).to be(true)
      end
    end

    context "with only double named splat" do
      let :parameters do
        Module.new { def trial(**one) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers true" do
        expect(analyzer.only_double_splats?).to be(true)
      end
    end

    context "with only single and double bare splats" do
      let :parameters do
        Module.new { def trial(*, **) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers false" do
        expect(analyzer.only_double_splats?).to be(false)
      end
    end

    context "with only single and double named splats" do
      let :parameters do
        Module.new { def trial(*one, **two) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers false" do
        expect(analyzer.only_double_splats?).to be(false)
      end
    end

    context "with no parameterss" do
      let(:parameters) { none }

      it "answers false" do
        expect(analyzer.only_double_splats?).to be(false)
      end
    end
  end

  describe "#only_single_splats?" do
    context "with only single bare splat" do
      let :parameters do
        Module.new { def trial(*) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers true" do
        expect(analyzer.only_single_splats?).to be(true)
      end
    end

    context "with only single named splat" do
      let :parameters do
        Module.new { def trial(*one) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers true" do
        expect(analyzer.only_single_splats?).to be(true)
      end
    end

    context "with only double bare splat" do
      let :parameters do
        Module.new { def trial(**) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers false" do
        expect(analyzer.only_single_splats?).to be(false)
      end
    end

    context "with only double named splat" do
      let :parameters do
        Module.new { def trial(**one) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers false" do
        expect(analyzer.only_single_splats?).to be(false)
      end
    end

    context "with only single and double bare splats" do
      let :parameters do
        Module.new { def trial(*, **) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers false" do
        expect(analyzer.only_single_splats?).to be(false)
      end
    end

    context "with only single and double named splats" do
      let :parameters do
        Module.new { def trial(*one, **two) = super }
              .instance_method(:trial)
              .parameters
      end

      it "answers false" do
        expect(analyzer.only_single_splats?).to be(false)
      end
    end

    context "with no parameterss" do
      let(:parameters) { none }

      it "answers false" do
        expect(analyzer.only_single_splats?).to be(false)
      end
    end
  end

  describe "#positionals" do
    context "when parameters exist" do
      let(:parameters) { comprehensive }

      it "answers array of names" do
        expect(analyzer.positionals).to eq(%i[one two])
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers empty array" do
        expect(analyzer.positionals).to eq([])
      end
    end
  end

  describe "#positionals?" do
    context "when parameters exist" do
      let(:parameters) { comprehensive }

      it "answers true" do
        expect(analyzer.positionals?).to be(true)
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers false" do
        expect(analyzer.positionals?).to be(false)
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

      it "answers empty array" do
        expect(analyzer.splats).to eq([])
      end
    end

    context "when named parameters exist" do
      let(:parameters) { comprehensive }

      it "answers array of names" do
        expect(analyzer.splats).to eq(%i[three six])
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers empty array" do
        expect(analyzer.splats).to eq([])
      end
    end
  end

  describe "#splats?" do
    context "when parameters exist" do
      let(:parameters) { comprehensive }

      it "answers true" do
        expect(analyzer.splats?).to be(true)
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers false" do
        expect(analyzer.splats?).to be(false)
      end
    end
  end

  describe "#to_a" do
    context "when parameters exist" do
      let(:parameters) { comprehensive }

      it "answers array" do
        expect(analyzer.to_a).to eq(comprehensive_proof)
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers empty array" do
        expect(analyzer.to_a).to eq([])
      end
    end
  end

  describe "#to_h" do
    context "when parameters exist" do
      let(:parameters) { comprehensive }

      it "answers hash" do
        expect(analyzer.to_h).to eq(
          block: :seven,
          key: :five,
          keyreq: :four,
          keyrest: :six,
          opt: :two,
          req: :one,
          rest: :three
        )
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers empty hash" do
        expect(analyzer.to_h).to eq({})
      end
    end
  end
end
