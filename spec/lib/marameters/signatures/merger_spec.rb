# frozen_string_literal: true

require "spec_helper"

RSpec.describe Marameters::Signatures::Merger do
  subject(:merger) { described_class.new }

  describe "#call" do
    let :all do
      [
        %i[req one],
        [:opt, :two, 2],
        %i[rest three],
        %i[keyreq four],
        [:key, :five, 5],
        %i[keyrest six],
        %i[block seven]
      ]
    end

    it "answers empty array with empty parameters" do
      expect(merger.call([], [])).to eq([])
    end

    it "answers anonymous fowards with full ancestor parameters and descandant forwards" do
      expect(merger.call(all, [[:rest], [:keyrest], [:block]])).to eq(
        [[:rest], [:keyrest], [:block]]
      )
    end

    it "answers required positionals with full ancestor parameters and single required parameter" do
      parameters = merger.call all, [%i[req descendant]]
      expect(parameters).to eq(
        [%i[req one], %i[req descendant], %i[opt two], [:rest], [:keyrest], [:block]]
      )
    end

    it "answers required positionals for ancestor and descendant" do
      parameters = merger.call [%i[req ancestor]], [%i[req descendant]]
      expect(parameters).to eq([%i[req ancestor], %i[req descendant]])
    end

    it "answers required positional for descendant only" do
      parameters = merger.call [], [%i[req test]]
      expect(parameters).to eq([%i[req test]])
    end

    it "answers optional positionals with full ancestor parameters and single optional parameter" do
      parameters = merger.call all, [[:opt, :descendant, 0]]
      expect(parameters).to eq(
        [%i[req one], %i[opt two], [:opt, :descendant, 0], [:rest], [:keyrest], [:block]]
      )
    end

    it "answers optional positionals for ancestor and descendant" do
      parameters = merger.call [%i[opt ancestor]], [%i[opt descendant]]
      expect(parameters).to eq([%i[opt ancestor], %i[opt descendant]])
    end

    it "answers optional positional for descendant only" do
      parameters = merger.call [], [%i[opt test]]
      expect(parameters).to eq([%i[opt test]])
    end

    it "answers required, optional, and single splat positionals when given the same" do
      parameters = merger.call [%i[req one], %i[opt two], %i[rest three]], [[:rest]]
      expect(parameters).to eq([%i[req one], %i[opt two], [:rest]])
    end

    it "answers required positional and anonymous single splat when given the same" do
      parameters = merger.call [%i[req test]], [[:rest]]
      expect(parameters).to eq([%i[req test], [:rest]])
    end

    it "answers optional positional and anonymous single splat when given the same" do
      parameters = merger.call [%i[opt test]], [[:rest]]
      expect(parameters).to eq([%i[opt test], [:rest]])
    end

    it "answers named single splat for full ancestor parameters and single splat parameter" do
      parameters = merger.call all, [%i[rest descendant]]

      expect(parameters).to eq(
        [%i[req one], %i[opt two], %i[rest descendant], [:keyrest], [:block]]
      )
    end

    it "answers anonymous single splat for ancestor and descendant single splats" do
      parameters = merger.call [%i[rest test]], [[:rest]]
      expect(parameters).to eq([[:rest]])
    end

    it "answers named single splat for anonymous ancestor and named descendant single splats" do
      parameters = merger.call [[:rest]], [%i[rest test]]
      expect(parameters).to eq([%i[rest test]])
    end

    it "answers requried keyword for full ancestor parameters and required descendant" do
      parameters = merger.call all, [%i[keyreq descendant]]
      expect(parameters).to eq([[:rest], %i[keyreq descendant], [:keyrest], [:block]])
    end

    it "answers required keyword for descendant only" do
      parameters = merger.call [%i[keyreq ancestor]], [%i[keyreq descendant]]
      expect(parameters).to eq([%i[keyreq descendant], [:keyrest]])
    end

    it "answers required keyword for empty ancestor and required descendant" do
      parameters = merger.call [], [%i[keyreq test]]
      expect(parameters).to eq([%i[keyreq test]])
    end

    it "answers optional keyword for full ancestor parameters and optional descendant" do
      parameters = merger.call all, [%i[key descendant]]
      expect(parameters).to eq([[:rest], %i[key descendant], [:keyrest], [:block]])
    end

    it "answers optional keyword for descendant only" do
      parameters = merger.call [%i[key ancestor]], [%i[key descendant]]
      expect(parameters).to eq([%i[key descendant], [:keyrest]])
    end

    it "answers optional keyword for empty ancestor and optional descendant" do
      parameters = merger.call [], [%i[key test]]
      expect(parameters).to eq([%i[key test]])
    end

    it "answers anonymous double splat with required keyword and anonymous double splat" do
      parameters = merger.call [%i[keyreq test]], [[:keyrest]]
      expect(parameters).to eq([[:keyrest]])
    end

    it "answers anonymous double splat with optional keyword and anonymous double splat" do
      parameters = merger.call [%i[key test]], [[:keyrest]]
      expect(parameters).to eq([[:keyrest]])
    end

    it "answers double splat for full ancestor parameters and descendant double splat" do
      parameters = merger.call all, [%i[keyrest descendant]]
      expect(parameters).to eq([[:rest], %i[keyrest descendant], [:block]])
    end

    it "answers double splat for ancestor and descendant double splats" do
      parameters = merger.call [%i[keyrest ancestor]], [[:keyrest]]
      expect(parameters).to eq([[:keyrest]])
    end

    it "answers named double splat for descendant named double splat" do
      parameters = merger.call [], [%i[keyrest test]]
      expect(parameters).to eq([%i[keyrest test]])
    end

    it "answers anonymous fowards with full ancestor parameters and named block" do
      parameters = merger.call all, [%i[block test]]
      expect(parameters).to eq([[:rest], [:keyrest], %i[block test]])
    end

    it "answers anonyous block with named ancestor and anonymous descendant blocks" do
      parameters = merger.call [%i[block test]], [[:block]]
      expect(parameters).to eq([[:block]])
    end

    it "answers anonymous block for anonymous ancestor and descendant" do
      parameters = merger.call [[:block]], [[:block]]
      expect(parameters).to eq([[:block]])
    end

    it "answers descendant named block for named ancestor and descendant blocks" do
      parameters = merger.call [%i[block ancestor]], [%i[block descendant]]
      expect(parameters).to eq([%i[block descendant]])
    end

    it "answers named block for descendant block only" do
      parameters = merger.call [], [%i[block test]]
      expect(parameters).to eq([%i[block test]])
    end

    it "includes defaults" do
      parameters = merger.call [], [[:opt, :two, 2], [:key, :three, 3]]
      expect(parameters).to eq([[:opt, :two, 2], [:key, :three, 3]])
    end

    it "removes duplicates" do
      parameters = merger.call [%i[req one]], [%i[req one], %i[req two], %i[req two]]
      expect(parameters).to eq([%i[req one], %i[req two]])
    end

    it "overrides duplicates with defaults" do
      parameters = merger.call [[:opt, :two, 1]], [[:opt, :two, 2]]
      expect(parameters).to eq([[:opt, :two, 2]])
    end

    it "answers sorted parameters" do
      parameters = merger.call [], [[:block], [:keyrest], [:rest], %i[opt one]]
      expect(parameters).to eq([%i[opt one], [:rest], [:keyrest], [:block]])
    end

    it "answers unique parameters" do
      parameters = merger.call [%i[req one], %i[rest one], %i[keyrest two], %i[block three]],
                               [%i[req one], [:rest], [:keyrest], [:block]]

      expect(parameters).to eq([%i[req one], [:rest], [:keyrest], [:block]])
    end

    it "answers anonymous forwards when ancestor and descendant are identical" do
      all = [
        %i[req one],
        %i[opt two],
        %i[rest three],
        %i[keyreq four],
        %i[key five],
        %i[keyrest six],
        %i[block seven]
      ]

      parameters = merger.call all, all

      expect(parameters).to eq([[:rest], [:keyrest], [:block]])
    end
  end
end
