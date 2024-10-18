# frozen_string_literal: true

require "spec_helper"

RSpec.describe Marameters::Signatures::Forwarder do
  subject(:forwarder) { described_class }

  describe "#call" do
    it "answers required positional name" do
      expect(forwarder.call(:req, :test)).to eq(:test)
    end

    it "answers optional positional name" do
      expect(forwarder.call(:opt, :test)).to eq(:test)
    end

    it "answers single splat with named positional splat" do
      expect(forwarder.call(:rest, :test)).to eq("*")
    end

    it "answers single splat with anonymous positional splat" do
      expect(forwarder.call(:rest)).to eq("*")
    end

    it "answers required keyword name" do
      expect(forwarder.call(:keyreq, :test)).to eq("test:")
    end

    it "answers optional keyword name" do
      expect(forwarder.call(:key, :test)).to eq("test:")
    end

    it "answers double splat with named keyword splat" do
      expect(forwarder.call(:keyrest, :test)).to eq("**")
    end

    it "answers double splat with anonymous keyword splat" do
      expect(forwarder.call(:keyrest)).to eq("**")
    end

    it "answers anonymous block with named block" do
      expect(forwarder.call(:block, :test)).to eq("&")
    end

    it "answers anonymous block with anonymous block" do
      expect(forwarder.call(:block)).to eq("&")
    end

    it "fails with argument error for unknown kind" do
      expectation = proc { forwarder.call :bogus }
      expect(&expectation).to raise_error(ArgumentError, "Unable to forward unknown kind: :bogus.")
    end
  end
end
