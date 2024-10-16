# frozen_string_literal: true

require "spec_helper"

RSpec.describe Marameters::Signatures::Reducer do
  subject(:reducer) { described_class }

  describe "#call" do
    it "includes defaults" do
      expect(reducer.call([[:opt, :one, 1], [:key, :two, 2]])).to eq(
        [[:opt, :one, 1], [:key, :two, 2]]
      )
    end

    it "includes nokey" do
      parameters = [[:nokey]]
      expect(reducer.call(parameters)).to eq([[:nokey]])
    end

    it "includes single splat when named" do
      expect(reducer.call([%i[rest test]])).to eq([%i[rest test]])
    end

    it "includes double splat when named" do
      expect(reducer.call([%i[keyrest test]])).to eq([%i[keyrest test]])
    end

    it "includes block when named" do
      expect(reducer.call([%i[block test]])).to eq([%i[block test]])
    end

    it "removes duplicate kinds" do
      expect(reducer.call([[:rest], [:rest]])).to eq([[:rest]])
    end

    it "removes duplicate kind and name" do
      expect(reducer.call([%i[req test], %i[req test]])).to eq([%i[req test]])
    end

    it "removes required keyword if double splat exists" do
      expect(reducer.call([[:keyrest], %i[keyreq test]])).to eq([[:keyrest], %i[keyreq test]])
    end

    it "removes optional keyword if double splat exists" do
      expect(reducer.call([[:keyrest], %i[key test]])).to eq([[:keyrest], %i[key test]])
    end

    it "overrides missing default" do
      expect(reducer.call([%i[key test], %i[key test test]])).to eq([%i[key test test]])
    end

    it "overrides existing default" do
      expect(reducer.call([[:key, :test, 1], %i[key test test]])).to eq([%i[key test test]])
    end

    it "prevents named splat override" do
      expect(reducer.call([[:rest], %i[rest test]])).to eq([[:rest]])
    end

    it "prevents named double splat override" do
      expect(reducer.call([[:keyrest], %i[keyrest test]])).to eq([[:keyrest]])
    end

    it "prevents named block override" do
      expect(reducer.call([[:block], %i[block test]])).to eq([[:block]])
    end
  end
end
