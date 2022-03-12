# frozen_string_literal: true

require "spec_helper"

RSpec.describe Marameters::Builder do
  subject(:builder) { described_class.new }

  describe "#call" do
    it "answers required parameter" do
      expect(builder.call(:req, :demo)).to eq(:demo)
    end

    it "answers optional parameter with default" do
      expect(builder.call(:opt, :demo)).to eq("demo = nil")
    end

    it "answers optional parameter with custom default" do
      expect(builder.call(:opt, :demo, default: "test")).to eq(%(demo = "test"))
    end

    it "answers bare single splat" do
      expect(builder.call(:rest, nil)).to eq("*")
    end

    it "answers named single splat" do
      expect(builder.call(:rest, :demo)).to eq("*demo")
    end

    it "answers required keyword" do
      expect(builder.call(:keyreq, :demo)).to eq("demo:")
    end

    it "answers optional keyword with default" do
      expect(builder.call(:key, :demo)).to eq("demo: nil")
    end

    it "answers optional keyword with custom default" do
      expect(builder.call(:key, :demo, default: "test")).to eq(%(demo: "test"))
    end

    it "answers bare double splat" do
      expect(builder.call(:keyrest, nil)).to eq("**")
    end

    it "answers named double splat" do
      expect(builder.call(:keyrest, :demo)).to eq("**demo")
    end

    it "answers bare block" do
      expect(builder.call(:block, nil)).to eq("&")
    end

    it "answers named block" do
      expect(builder.call(:block, :demo)).to eq("&demo")
    end
  end
end
