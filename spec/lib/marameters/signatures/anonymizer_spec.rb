# frozen_string_literal: true

require "spec_helper"

RSpec.describe Marameters::Signatures::Anonymizer do
  subject(:anonymizer) { described_class }

  describe "#call" do
    it "answers required positional" do
      expect(anonymizer.call(%i[req test])).to eq([%i[req test]])
    end

    it "answers optional positional" do
      expect(anonymizer.call(%i[opt test])).to eq([%i[opt test]])
    end

    it "answers bare single splat" do
      expect(anonymizer.call(%i[rest test])).to eq([[:rest]])
    end

    it "removes nokey" do
      expect(anonymizer.call([:nokey])).to eq([])
    end

    it "answers bare double splat for required double splat" do
      expect(anonymizer.call(%i[keyreq test])).to eq([[:keyrest]])
    end

    it "answers bare double splat for optional double splat" do
      expect(anonymizer.call(%i[key test])).to eq([[:keyrest]])
    end

    it "answers bare double splat for double splat" do
      expect(anonymizer.call(%i[keyrest test])).to eq([[:keyrest]])
    end

    it "answers bare block" do
      expect(anonymizer.call(%i[block test])).to eq([[:block]])
    end

    it "answers answer non-uniques" do
      all = [
        %i[req one],
        %i[opt two],
        %i[rest three],
        %i[keyreq four],
        %i[key five],
        %i[keyrest six],
        %i[block seven]
      ]

      expect(anonymizer.call(*all)).to eq(
        [%i[req one], %i[opt two], [:rest], [:keyrest], [:keyrest], [:keyrest], [:block]]
      )
    end
  end
end
