# frozen_string_literal: true

require "spec_helper"

RSpec.describe Marameters::Signatures::Super do
  subject(:signature) { described_class.new }

  describe "#initialize" do
    it "is frozen" do
      expect(signature.frozen?).to be(true)
    end
  end

  describe "#call" do
    context "with all kinds" do
      let :ancestor do
        Marameters::Probe.new [
          %i[req one],
          [:opt, :two, 2],
          %i[rest three],
          %i[keyreq four],
          [:key, :five, 5],
          %i[keyrest six],
          %i[block seven]
        ]
      end

      let :descendant do
        Marameters::Probe.new [
          %i[req one],
          [:opt, :two, 2],
          %i[rest three],
          %i[keyreq four],
          [:key, :five, 5],
          %i[keyrest six],
          %i[block seven]
        ]
      end

      it "answers all arguments" do
        expect(signature.call(ancestor, descendant)).to eq(
          "one, two, *three, four:, five:, **six, &seven"
        )
      end
    end

    it "sorts by position" do
      ancestor = Marameters::Probe.new [[:block], %i[keyreq two], %i[req one]]
      descendant = Marameters::Probe.new []

      expect(signature.call(ancestor, descendant)).to eq("*, **, &")
    end

    it "answers required positional" do
      ancestor = Marameters::Probe.new [%i[req one]]
      descendant = Marameters::Probe.new [%i[req two]]

      expect(signature.call(ancestor, descendant)).to eq("one")
    end

    it "answers optional positional" do
      ancestor = Marameters::Probe.new [%i[opt one]]
      descendant = Marameters::Probe.new [%i[opt two]]

      expect(signature.call(ancestor, descendant)).to eq("one")
    end

    it "answers optional positional with duplicate names and different defaults" do
      ancestor = Marameters::Probe.new [[:opt, :one, 1]]
      descendant = Marameters::Probe.new [[:opt, :one, 10]]

      expect(signature.call(ancestor, descendant)).to eq("one")
    end

    it "answers required and optional positionals with no matching positionals" do
      ancestor = Marameters::Probe.new [%i[req one], %i[opt two]]
      descendant = Marameters::Probe.new [%i[req alt_a], %i[opt alt_b]]

      expect(signature.call(ancestor, descendant)).to eq("one, two")
    end

    it "answers anonymous single splat with anonymous single splats" do
      ancestor = Marameters::Probe.new [[:rest]]
      descendant = Marameters::Probe.new [[:rest]]

      expect(signature.call(ancestor, descendant)).to eq("*")
    end

    it "answers anonymous single splat when descendant has no positionals" do
      ancestor = Marameters::Probe.new [%i[req one]]
      descendant = Marameters::Probe.new [[:keyrest]]

      expect(signature.call(ancestor, descendant)).to eq("*")
    end

    it "answers named single splat with mixed single splats" do
      ancestor = Marameters::Probe.new [[:rest]]
      descendant = Marameters::Probe.new [%i[rest test]]

      expect(signature.call(ancestor, descendant)).to eq("*test")
    end

    it "answers empty string when ancestor prevents keywords" do
      ancestor = Marameters::Probe.new [[:nokey]]
      descendant = Marameters::Probe.new [%i[keyreq one], %i[key two]]

      expect(signature.call(ancestor, descendant)).to eq("")
    end

    it "answers empty string when descendant prevents keywords" do
      ancestor = Marameters::Probe.new [%i[keyreq one], %i[key two]]
      descendant = Marameters::Probe.new [[:nokey]]

      expect(signature.call(ancestor, descendant)).to eq("")
    end

    it "answers required keyword with duplicate required keywords" do
      ancestor = Marameters::Probe.new [%i[keyreq one]]
      descendant = Marameters::Probe.new [%i[keyreq one]]

      expect(signature.call(ancestor, descendant)).to eq("one:")
    end

    it "answers optional keyword with duplicate names" do
      ancestor = Marameters::Probe.new [%i[key one]]
      descendant = Marameters::Probe.new [%i[key one]]

      expect(signature.call(ancestor, descendant)).to eq("one:")
    end

    it "answers optional keyword with duplicate names and different defaults" do
      ancestor = Marameters::Probe.new [[:key, :one, 1]]
      descendant = Marameters::Probe.new [[:key, :one, 10]]

      expect(signature.call(ancestor, descendant)).to eq("one:")
    end

    it "answers anonymous double splat with different required keywords" do
      ancestor = Marameters::Probe.new [%i[keyreq one]]
      descendant = Marameters::Probe.new [%i[keyreq two]]

      expect(signature.call(ancestor, descendant)).to eq("**")
    end

    it "answers anonymous double splat with different optional keywords" do
      ancestor = Marameters::Probe.new [%i[key one]]
      descendant = Marameters::Probe.new [%i[key two]]

      expect(signature.call(ancestor, descendant)).to eq("**")
    end

    it "answers anonymous double splat with anonymous double splats" do
      ancestor = Marameters::Probe.new [[:keyrest]]
      descendant = Marameters::Probe.new [[:keyrest]]

      expect(signature.call(ancestor, descendant)).to eq("**")
    end

    it "answers named double splat with mixed double splats" do
      ancestor = Marameters::Probe.new [[:keyrest]]
      descendant = Marameters::Probe.new [%i[keyrest test]]

      expect(signature.call(ancestor, descendant)).to eq("**test")
    end

    it "answers anonymous block with anonymous blocks" do
      ancestor = Marameters::Probe.new [[:block]]
      descendant = Marameters::Probe.new [%i[block]]

      expect(signature.call(ancestor, descendant)).to eq("&")
    end

    it "answers named block with mixed blocks" do
      ancestor = Marameters::Probe.new [[:block]]
      descendant = Marameters::Probe.new [%i[block test]]

      expect(signature.call(ancestor, descendant)).to eq("&test")
    end

    it "answers empty string with empty ancestor" do
      expect(signature.call([], [])).to eq("")
    end
  end
end
