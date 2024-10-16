# frozen_string_literal: true

require "spec_helper"

RSpec.describe Marameters::Signatures::Reducer do
  subject(:reducer) { described_class }

  describe "#call" do
    let(:ancestor) { [%i[req one], %i[opt two], [:rest], [:keyrest], [:block]] }

    it "forwards arguments when ancestor and descendant parameters match" do
      descendant = [
        %i[req one],
        %i[opt two],
        %i[rest three],
        %i[keyreq four],
        %i[key five],
        %i[keyrest six],
        %i[block seven]
      ]

      expect(reducer.call(ancestor, descendant)).to eq([%i[rest], [:keyrest], [:block]])
    end

    it "adds/overrides with full custom parameters" do
      descendant = [
        %i[req alt_a],
        %i[opt alt_b],
        %i[rest alt_c],
        %i[keyreq alt_d],
        %i[key alt_e],
        %i[keyrest alt_f],
        %i[block alt_g]
      ]

      expect(reducer.call(ancestor, descendant)).to eq(
        [
          %i[req one],
          %i[req alt_a],
          %i[opt two],
          %i[opt alt_b],
          %i[rest alt_c],
          [:keyrest],
          [:block],
          %i[req alt_a],
          [:opt, :alt_b, 0]
        ]
      )
    end

    it "includes required positional with full ancestor parameters" do
      expect(reducer.call(ancestor, [%i[req extra]])).to eq(
        [%i[req one], %i[opt two], [:rest], [:keyrest], [:block], %i[req extra]]
      )
    end

    it "includes optional positional with full ancestor parameters" do
      expect(reducer.call(ancestor, [[:opt, :extra, 0]])).to eq(
        [%i[req one], %i[opt two], [:rest], [:keyrest], [:block], [:opt, :extra, 0]]
      )
    end

    it "overrides optional positional default" do
      ancestor = [[:opt, :test, 1]]
      descendant = [[:opt, :test, 10]]

      expect(reducer.call(ancestor, descendant)).to eq(descendant)
    end

    it "includes anonymous single splat positional with full ancestor parameters" do
      expect(reducer.call(ancestor, [[:rest]])).to eq(
        [%i[req one], %i[opt two], [:rest], [:keyrest], [:block]]
      )
    end

    it "includes named single splat positional with full ancestor parameters" do
      expect(reducer.call(ancestor, [%i[rest three]])).to eq(
        [%i[req one], %i[opt two], %i[rest three], [:keyrest], [:block]]
      )
    end

    it "includes required keyword with full ancestor parameters" do
      expect(reducer.call(ancestor, [%i[keyreq extra]])).to eq(
        [[:rest], [:keyrest], [:block], %i[keyreq extra]]
      )
    end

    it "includes optional keyword with full ancestor parameters" do
      expect(reducer.call(ancestor, [%i[key extra extra]])).to eq(
        [[:rest], [:keyrest], [:block], %i[key extra extra]]
      )
    end

    it "overrides optional keyword default" do
      ancestor = [[:key, :test, 1]]
      descendant = [[:key, :test, 10]]

      expect(reducer.call(ancestor, descendant)).to eq(descendant)
    end

    it "includes anonymous double splat with full ancestor parameters" do
      expect(reducer.call(ancestor, [[:keyrest]])).to eq([[:rest], [:keyrest], [:block]])
    end

    it "includes named double splat with full ancestor parameters" do
      expect(reducer.call(ancestor, [%i[keyrest extra]])).to eq(
        [[:rest], %i[keyrest extra], [:block]]
      )
    end

    it "includes anonymous block with full ancestor parameters" do
      expect(reducer.call(ancestor, [[:block]])).to eq([%i[rest], [:keyrest], [:block]])
    end

    it "includes named block with full ancestor parameters" do
      expect(reducer.call(ancestor, [%i[block test]])).to eq([%i[rest], [:keyrest], %i[block test]])
    end

    it "answers empty parameters with empty ancestor and descendant" do
      expect(reducer.call([], [])).to eq([])
    end

    it "answers anonymous forwards with empty descendant parameters" do
      expect(reducer.call(ancestor, [])).to eq([%i[rest], [:keyrest], [:block]])
    end
  end
end
