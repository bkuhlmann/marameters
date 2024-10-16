# frozen_string_literal: true

require "spec_helper"

RSpec.describe Marameters::Builder do
  subject(:builder) { described_class.new }

  describe "#call" do
    it "answers required parameter" do
      expect(builder.call(:req, :test)).to eq(:test)
    end

    it "answers optional parameter with default" do
      expect(builder.call(:opt, :test)).to eq("test = nil")
    end

    it "answers optional parameter with custom default" do
      expect(builder.call(:opt, :test, default: "test")).to eq(%(test = "test"))
    end

    it "answers bare single splat" do
      expect(builder.call(:rest, nil)).to eq("*")
    end

    it "answers named single splat" do
      expect(builder.call(:rest, :test)).to eq("*test")
    end

    it "answers no keywords" do
      expect(builder.call(:nokey)).to eq("**nil")
    end

    it "answers required keyword" do
      expect(builder.call(:keyreq, :test)).to eq("test:")
    end

    it "answers optional keyword with default" do
      expect(builder.call(:key, :test)).to eq("test: nil")
    end

    it "answers optional keyword with custom default" do
      expect(builder.call(:key, :test, default: "test")).to eq(%(test: "test"))
    end

    it "answers bare double splat" do
      expect(builder.call(:keyrest, nil)).to eq("**")
    end

    it "answers named double splat" do
      expect(builder.call(:keyrest, :test)).to eq("**test")
    end

    it "answers bare block" do
      expect(builder.call(:block, nil)).to eq("&")
    end

    it "answers named block" do
      expect(builder.call(:block, :test)).to eq("&test")
    end
  end
end
