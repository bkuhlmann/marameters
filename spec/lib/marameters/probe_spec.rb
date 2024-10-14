# frozen_string_literal: true

require "spec_helper"

RSpec.describe Marameters::Probe do
  subject(:probe) { described_class.new parameters }

  include_context "with parameters"

  describe ".of" do
    it "answers parameters with no inheritance" do
      parameters = described_class.of(test_module, :named).flat_map(&:to_a)
      expect(parameters).to eq(named_proof)
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

  describe "#initialize" do
    let(:parameters) { none }

    it "is frozen" do
      expect(probe.frozen?).to be(true)
    end
  end

  describe "#<=>" do
    let(:first) { described_class.new named }
    let(:second) { described_class.new none }

    it "answers one when greater than" do
      expect(first <=> second).to eq(1)
    end

    it "answers negative one when less than" do
      expect(second <=> first).to eq(-1)
    end

    it "ansers zero when identical" do
      similar = described_class.new named
      expect(first <=> similar).to eq(0)
    end
  end

  shared_examples "an equal" do |method|
    let(:first) { described_class.new named }
    let(:second) { described_class.new none }

    it "answers true when equal" do
      similar = described_class.new named
      expect(first.public_send(method, similar)).to be(true)
    end

    it "answers false when not equal" do
      expect(first.public_send(method, second)).to be(false)
    end
  end

  describe "#==" do
    it_behaves_like "an equal", :==
  end

  describe "#eql?" do
    it_behaves_like "an equal", :eql?
  end

  describe "#any?" do
    context "when parameters exist" do
      let(:parameters) { named }

      it "answers true" do
        expect(probe.any?).to be(true)
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers false" do
        expect(probe.any?).to be(false)
      end
    end
  end

  describe "#empty?" do
    context "when parameters exist" do
      let(:parameters) { named }

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

  describe "#hash" do
    let(:parameters) { named }

    it "answers parameters' hash" do
      expect(probe.hash).to eq(named.hash)
    end
  end

  describe "#include?" do
    let(:parameters) { named }

    it "answers true when parameter exists" do
      expect(probe.include?(%i[req one])).to be(true)
    end

    it "answers false when parameter doesn't exist" do
      expect(probe.include?(%i[req test])).to be(false)
    end
  end

  describe "#inspect" do
    let(:parameters) { [%i[req test]] }

    it "answers parameters array as a string" do
      expect(probe.inspect).to eq(parameters.to_s)
    end
  end

  describe "#keywords" do
    context "when parameters exist" do
      let(:parameters) { named }

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
      let(:parameters) { named }

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
    let(:parameters) { named }

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
      let(:parameters) { named }

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
      let(:parameters) { named }

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
      let(:parameters) { named }

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
    context "with named parameters" do
      let(:parameters) { named }

      it "answers names" do
        expect(probe.names).to eq(%i[one two three four five six seven])
      end
    end

    context "with named and anonymous parameters" do
      let(:parameters) { mixed }

      it "answers names" do
        expect(probe.names).to eq(%i[one two * four five ** &])
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
        Module.new { def test(*) = super }
              .instance_method(:test)
              .parameters
      end

      it "answers true" do
        expect(probe.only_bare_splats?).to be(true)
      end
    end

    context "with only single named splat" do
      let :parameters do
        Module.new { def test(*one) = super }
              .instance_method(:test)
              .parameters
      end

      it "answers false" do
        expect(probe.only_bare_splats?).to be(false)
      end
    end

    context "with only double splat" do
      let :parameters do
        Module.new { def test(**) = super }
              .instance_method(:test)
              .parameters
      end

      it "answers true" do
        expect(probe.only_bare_splats?).to be(true)
      end
    end

    context "with only double named splat" do
      let :parameters do
        Module.new { def test(**one) = super }
              .instance_method(:test)
              .parameters
      end

      it "answers false" do
        expect(probe.only_bare_splats?).to be(false)
      end
    end

    context "with only single and double bare splats" do
      let :parameters do
        Module.new { def test(*, **) = super }
              .instance_method(:test)
              .parameters
      end

      it "answers true" do
        expect(probe.only_bare_splats?).to be(true)
      end
    end

    context "with only single and double named splats" do
      let :parameters do
        Module.new { def test(*one, **two) = super }
              .instance_method(:test)
              .parameters
      end

      it "answers false" do
        expect(probe.only_bare_splats?).to be(false)
      end
    end

    context "with splats and positionals" do
      let :parameters do
        Module.new { def test(one, *, **) = super }
              .instance_method(:test)
              .parameters
      end

      it "answers false" do
        expect(probe.only_bare_splats?).to be(false)
      end
    end

    context "with splats and keywords" do
      let :parameters do
        Module.new { def test(*, one:, **) = super }
              .instance_method(:test)
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
        Module.new { def test(*) = super }
              .instance_method(:test)
              .parameters
      end

      it "answers false" do
        expect(probe.only_double_splats?).to be(false)
      end
    end

    context "with only double splat" do
      let :parameters do
        Module.new { def test(**) = super }
              .instance_method(:test)
              .parameters
      end

      it "answers true" do
        expect(probe.only_double_splats?).to be(true)
      end
    end

    context "with only double named splat" do
      let :parameters do
        Module.new { def test(**one) = super }
              .instance_method(:test)
              .parameters
      end

      it "answers true" do
        expect(probe.only_double_splats?).to be(true)
      end
    end

    context "with only single and double splats" do
      let :parameters do
        Module.new { def test(*, **) = super }
              .instance_method(:test)
              .parameters
      end

      it "answers false" do
        expect(probe.only_double_splats?).to be(false)
      end
    end

    context "with double splat and positionals" do
      let :parameters do
        Module.new { def test(one, two = 2, **) = super }
              .instance_method(:test)
              .parameters
      end

      it "answers false" do
        expect(probe.only_double_splats?).to be(false)
      end
    end

    context "with double splat and keywords" do
      let :parameters do
        Module.new { def test(one:, two: 2, **) = super }
              .instance_method(:test)
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
        Module.new { def test(*) = super }
              .instance_method(:test)
              .parameters
      end

      it "answers true" do
        expect(probe.only_single_splats?).to be(true)
      end
    end

    context "with only single named splat" do
      let :parameters do
        Module.new { def test(*one) = super }
              .instance_method(:test)
              .parameters
      end

      it "answers true" do
        expect(probe.only_single_splats?).to be(true)
      end
    end

    context "with only double splat" do
      let :parameters do
        Module.new { def test(**) = super }
              .instance_method(:test)
              .parameters
      end

      it "answers false" do
        expect(probe.only_single_splats?).to be(false)
      end
    end

    context "with only single and double splats" do
      let :parameters do
        Module.new { def test(*, **) = super }
              .instance_method(:test)
              .parameters
      end

      it "answers false" do
        expect(probe.only_single_splats?).to be(false)
      end
    end

    context "with single splat and positionals" do
      let :parameters do
        Module.new { def test(one, two = 2, *) = super }
              .instance_method(:test)
              .parameters
      end

      it "answers false" do
        expect(probe.only_single_splats?).to be(false)
      end
    end

    context "with single splat and keywords" do
      let :parameters do
        Module.new { def test(*, one:, two: 2) = super }
              .instance_method(:test)
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
      let(:parameters) { named }

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
      let(:parameters) { named }

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

  describe "#positionals_and_maybe_keywords?" do
    context "with required positional" do
      let :parameters do
        Module.new { def test(one) = super }
              .instance_method(:test)
              .parameters
      end

      it "answers true" do
        expect(probe.positionals_and_maybe_keywords?).to be(true)
      end
    end

    context "with optional positional" do
      let :parameters do
        Module.new { def test(one = 1) = super }
              .instance_method(:test)
              .parameters
      end

      it "answers true" do
        expect(probe.positionals_and_maybe_keywords?).to be(true)
      end
    end

    context "with required and optional positionals" do
      let :parameters do
        Module.new { def test(one, two = 2) = super }
              .instance_method(:test)
              .parameters
      end

      it "answers true" do
        expect(probe.positionals_and_maybe_keywords?).to be(true)
      end
    end

    context "with positionals and required keyword" do
      let :parameters do
        Module.new { def test(one, two = 2, three:) = super }
              .instance_method(:test)
              .parameters
      end

      it "answers true" do
        expect(probe.positionals_and_maybe_keywords?).to be(true)
      end
    end

    context "with positionals and optional keyword" do
      let :parameters do
        Module.new { def test(one, two = 2, three: 3) = super }
              .instance_method(:test)
              .parameters
      end

      it "answers true" do
        expect(probe.positionals_and_maybe_keywords?).to be(true)
      end
    end

    context "with positionals and double splat" do
      let :parameters do
        Module.new { def test(one, two = 2, **) = super }
              .instance_method(:test)
              .parameters
      end

      it "answers true" do
        expect(probe.positionals_and_maybe_keywords?).to be(true)
      end
    end

    context "with positionals and block" do
      let :parameters do
        Module.new { def test(one, two = 2, &) = super }
              .instance_method(:test)
              .parameters
      end

      it "answers true" do
        expect(probe.positionals_and_maybe_keywords?).to be(true)
      end
    end

    context "with no parameterss" do
      let(:parameters) { none }

      it "answers false" do
        expect(probe.positionals_and_maybe_keywords?).to be(false)
      end
    end
  end

  shared_examples "an array" do |method|
    context "when parameters exist" do
      let(:parameters) { named }

      it "answers array" do
        expect(probe.public_send(method)).to eq(named_proof)
      end
    end

    context "when parameters don't exist" do
      let(:parameters) { none }

      it "answers empty array" do
        expect(probe.public_send(method)).to eq([])
      end
    end
  end

  describe "#deconstruct" do
    it_behaves_like "an array", :deconstruct
  end

  describe "#to_a" do
    it_behaves_like "an array", :to_a
  end
end
