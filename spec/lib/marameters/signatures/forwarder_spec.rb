# frozen_string_literal: true

require "spec_helper"

RSpec.describe Marameters::Signatures::Forwarder do
  subject(:forwarder) { described_class }

  describe "#call" do
    it "answers required positional" do
      expect(forwarder.call(:req, :test)).to eq(:test)
    end

    it "answers optional positional" do
      expect(forwarder.call(:opt, :test)).to eq(:test)
    end

    it "answers anonymous single splat" do
      expect(forwarder.call(:rest)).to eq("*")
    end

    it "answers named single splat" do
      expect(forwarder.call(:rest, :test)).to eq("*test")
    end

    it "answers empty string for no keywords" do
      expect(forwarder.call(:nokey)).to eq("")
    end

    it "answers required keyword" do
      expect(forwarder.call(:keyreq, :test)).to eq("test:")
    end

    it "answers optional keyword" do
      expect(forwarder.call(:key, :test)).to eq("test:")
    end

    it "answers anonymous double splat" do
      expect(forwarder.call(:keyrest)).to eq("**")
    end

    it "answers named double splat" do
      expect(forwarder.call(:keyrest, :test)).to eq("**test")
    end

    it "answers anonymous block" do
      expect(forwarder.call(:block)).to eq("&")
    end

    it "answers named block" do
      expect(forwarder.call(:block, :test)).to eq("&test")
    end

    it "fails with argument error for unknown kind" do
      expectation = proc { forwarder.call :bogus }
      expect(&expectation).to raise_error(ArgumentError, "Unable to forward unknown kind: :bogus.")
    end
  end
end
