# frozen_string_literal: true

require "spec_helper"

RSpec.describe Marameters::Signatures::Inheritor do
  subject(:inheritor) { described_class.new }

  describe "#initialize" do
    it "is frozen" do
      expect(inheritor.frozen?).to be(true)
    end
  end

  describe "#call" do
    let :ancestor do
      Marameters::Probe.new [
        %i[req one],
        %i[opt two],
        %i[rest three],
        %i[keyreq four],
        %i[key five],
        %i[keyrest six],
        %i[block seven]
      ]
    end

    it "forwards arguments when ancestor and descendant parameters are identical" do
      descendant = Marameters::Probe.new [
        %i[req one],
        %i[opt two],
        %i[rest three],
        %i[keyreq four],
        %i[key five],
        %i[keyrest six],
        %i[block seven]
      ]

      expect(inheritor.call(ancestor, descendant)).to eq(
        [
          %i[req one],
          %i[opt two],
          %i[rest three],
          %i[keyreq four],
          %i[key five],
          %i[keyrest six],
          %i[block seven]
        ]
      )
    end

    it "merges with full custom parameters" do
      descendant = Marameters::Probe.new [
        %i[req alt_a],
        %i[opt alt_b],
        %i[rest alt_c],
        %i[keyreq alt_d],
        %i[key alt_e],
        %i[keyrest alt_f],
        %i[block alt_g]
      ]

      expect(inheritor.call(ancestor, descendant)).to eq(
        [
          %i[req one],
          %i[req alt_a],
          %i[opt two],
          %i[opt alt_b],
          %i[rest alt_c],
          %i[keyreq alt_d],
          %i[key alt_e],
          %i[keyrest alt_f],
          %i[block alt_g]
        ]
      )
    end

    it "includes required positional with full ancestor parameters" do
      descendant = Marameters::Probe.new [%i[req extra]]

      expect(inheritor.call(ancestor, descendant)).to eq(
        [
          %i[req one],
          %i[req extra],
          %i[opt two],
          %i[rest three],
          %i[keyrest six],
          %i[block seven]
        ]
      )
    end

    it "includes optional positional with full ancestor parameters" do
      descendant = Marameters::Probe.new [[:opt, :extra, 0]]
      expect(inheritor.call(ancestor, descendant)).to eq(
        [
          %i[req one],
          %i[opt two],
          [:opt, :extra, 0],
          %i[rest three],
          %i[keyrest six],
          %i[block seven]
        ]
      )
    end

    it "overrides existing optional positional with custom value" do
      ancestor = Marameters::Probe.new [[:opt, :test, 1]]
      descendant = Marameters::Probe.new [[:opt, :test, 10]]

      expect(inheritor.call(ancestor, descendant)).to eq(descendant.to_a)
    end

    it "overrides existing optional positional with nil" do
      ancestor = Marameters::Probe.new [[:opt, :test, 1]]
      descendant = Marameters::Probe.new [%i[opt test]]

      expect(inheritor.call(ancestor, descendant)).to eq(descendant.to_a)
    end

    it "includes anonymous single splat positional with full ancestor parameters" do
      descendant = Marameters::Probe.new [[:rest]]

      expect(inheritor.call(ancestor, descendant)).to eq(
        [[:rest], %i[keyrest six], %i[block seven]]
      )
    end

    it "includes named single splat positional with full ancestor parameters" do
      descendant = Marameters::Probe.new [%i[rest three]]

      expect(inheritor.call(ancestor, descendant)).to eq(
        [%i[rest three], %i[keyrest six], %i[block seven]]
      )
    end

    it "includes required and optional keywords when ancestor prevents keywords" do
      ancestor = Marameters::Probe.new [[:nokey]]
      descendant = Marameters::Probe.new [%i[keyreq one], [:key, :two, 2]]

      expect(inheritor.call(ancestor, descendant)).to eq([%i[keyreq one], [:key, :two, 2]])
    end

    it "includes required and optional keywords when ancestor has no parameters" do
      ancestor = Marameters::Probe.new []
      descendant = Marameters::Probe.new [%i[keyreq one], [:key, :two, 2]]

      expect(inheritor.call(ancestor, descendant)).to eq([%i[keyreq one], [:key, :two, 2]])
    end

    it "includes required keyword with full ancestor parameters" do
      descendant = Marameters::Probe.new [%i[keyreq extra]]

      expect(inheritor.call(ancestor, descendant)).to eq(
        [%i[rest three], %i[keyreq extra], [:keyrest], %i[block seven]]
      )
    end

    it "includes additional required keyword" do
      ancestor = Marameters::Probe.new [%i[keyreq one]]
      descendant = Marameters::Probe.new [%i[keyreq two]]

      expect(inheritor.call(ancestor, descendant)).to eq([%i[keyreq two], [:keyrest]])
    end

    it "includes optional keyword with full ancestor parameters" do
      descendant = Marameters::Probe.new [%i[key extra extra]]

      expect(inheritor.call(ancestor, descendant)).to eq(
        [%i[rest three], %i[key extra extra], [:keyrest], %i[block seven]]
      )
    end

    it "answers only descendant optional keyword when ancestor has no default" do
      ancestor = Marameters::Probe.new [%i[key one]]
      descendant = Marameters::Probe.new [[:key, :two, 2]]

      expect(inheritor.call(ancestor, descendant)).to eq([[:key, :two, 2], [:keyrest]])
    end

    it "overrides optional keyword default" do
      ancestor = Marameters::Probe.new [[:key, :test, 1]]
      descendant = Marameters::Probe.new [[:key, :test, 10]]

      expect(inheritor.call(ancestor, descendant)).to eq([[:key, :test, 10]])
    end

    it "includes anonymous double splat with full ancestor parameters" do
      descendant = Marameters::Probe.new [[:keyrest]]

      expect(inheritor.call(ancestor, descendant)).to eq(
        [%i[rest three], [:keyrest], %i[block seven]]
      )
    end

    it "includes named double splat with full ancestor parameters" do
      descendant = Marameters::Probe.new [%i[keyrest extra]]

      expect(inheritor.call(ancestor, descendant)).to eq(
        [%i[rest three], %i[keyrest extra], %i[block seven]]
      )
    end

    it "includes anonymous block with full ancestor parameters" do
      descendant = Marameters::Probe.new [[:block]]

      expect(inheritor.call(ancestor, descendant)).to eq(
        [%i[rest three], %i[keyrest six], [:block]]
      )
    end

    it "includes named block with full ancestor parameters" do
      descendant = Marameters::Probe.new [%i[block test]]

      expect(inheritor.call(ancestor, descendant)).to eq(
        [%i[rest three], %i[keyrest six], %i[block test]]
      )
    end

    it "answers anonymous forwards with empty descendant parameters" do
      descendant = Marameters::Probe.new []

      expect(inheritor.call(ancestor, descendant)).to eq(
        [%i[rest three], %i[keyrest six], %i[block seven]]
      )
    end

    it "answers empty parameters with empty ancestor and descendant" do
      ancestor = Marameters::Probe.new []
      descendant = Marameters::Probe.new []

      expect(inheritor.call(ancestor, descendant)).to eq([])
    end
  end
end
