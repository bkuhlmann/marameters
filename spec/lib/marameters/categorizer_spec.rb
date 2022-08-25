# frozen_string_literal: true

require "spec_helper"

RSpec.describe Marameters::Categorizer do
  subject(:categorizer) { described_class.new comprehensive }

  include_context "with parameters"

  describe "#call" do
    let(:function) { proc { "test" } }
    let(:maximum) { [1, 2, [98, 99], {four: 4}, {five: 5}, {twenty: 20, thirty: 30}, function] }

    it "answers empty attributes when given empty arguments" do
      expect(categorizer.call([])).to have_attributes(positionals: [nil], keywords: {}, block: nil)
    end

    it "answers empty attributes when no parameters exist for arguments" do
      categorizer = described_class.new none

      expect(categorizer.call([1, 2, 3])).to have_attributes(
        positionals: [],
        keywords: {},
        block: nil
      )
    end

    it "clears and rebuilds attributes when called multiple times" do
      arguments = [1, 2, nil, {four: 4}]
      categorizer.call arguments

      expect(categorizer.call(arguments)).to have_attributes(
        positionals: [1, 2],
        keywords: {four: 4},
        block: nil
      )
    end

    it "answers attributes for forwarded arguments" do
      struct = Struct.new(:a, keyword_init: true) { def self.for(...) = new(...) }

      categorizer = struct.method(:for)
                          .parameters
                          .then { |parameters| described_class.new parameters }

      expect(categorizer.call(a: 1)).to have_attributes(
        positionals: [:a, 1],
        keywords: {},
        block: nil
      )
    end

    it "answers attributes for splatted/anonymous arguments" do
      categorizer = Module.new { def trial(*, **, &) = super }
                          .instance_method(:trial)
                          .parameters
                          .then { |parameters| described_class.new parameters }

      expect(categorizer.call(maximum)).to have_attributes(
        positionals: [1, 2, 98, 99],
        keywords: {four: 4, five: 5, twenty: 20, thirty: 30},
        block: function
      )
    end

    it "answers attributes for single splats" do
      categorizer = Module.new { def trial(*) = super }
                          .instance_method(:trial)
                          .parameters
                          .then { |parameters| described_class.new parameters }

      expect(categorizer.call(maximum)).to have_attributes(
        positionals: [1, 2, 98, 99],
        keywords: {},
        block: nil
      )
    end

    it "answers attributes for double splats" do
      categorizer = Module.new { def trial(**) = super }
                          .instance_method(:trial)
                          .parameters
                          .then { |parameters| described_class.new parameters }

      expect(categorizer.call(maximum)).to have_attributes(
        positionals: [],
        keywords: {four: 4, five: 5, twenty: 20, thirty: 30},
        block: nil
      )
    end

    it "answers attributes for anonymous block" do
      categorizer = Module.new { def trial(&) = super }
                          .instance_method(:trial)
                          .parameters
                          .then { |parameters| described_class.new parameters }

      expect(categorizer.call(maximum)).to have_attributes(
        positionals: [],
        keywords: {},
        block: function
      )
    end

    it "answers minimum attributes" do
      expect(categorizer.call([1, 2, nil, {four: 4}])).to have_attributes(
        positionals: [1, 2],
        keywords: {four: 4},
        block: nil
      )
    end

    it "answers with minimum attributes filled for using last position" do
      arguments = [nil, nil, nil, {four: 4}, nil, nil, function]

      expect(categorizer.call(arguments)).to have_attributes(
        positionals: [nil],
        keywords: {four: 4},
        block: function
      )
    end

    it "answers with minimum but required attributes filled for using last position" do
      arguments = [:a, nil, nil, {four: 4}, nil, nil, function]

      expect(categorizer.call(arguments)).to have_attributes(
        positionals: [:a],
        keywords: {four: 4},
        block: function
      )
    end

    it "answers maximum attributes" do
      arguments = [1, 2, [98, 99], {four: 4}, {five: 5}, {twenty: 20, thirty: 30}, function]

      expect(categorizer.call(arguments)).to have_attributes(
        positionals: [1, 2, 98, 99],
        keywords: {four: 4, five: 5, twenty: 20, thirty: 30},
        block: function
      )
    end

    it "answers attributes for struct" do
      struct = Struct.new :a, :b, keyword_init: true
      categorizer = described_class.new struct.method(:new).parameters

      expect(categorizer.call(a: 1)).to have_attributes(
        positionals: [:a, 1],
        keywords: {},
        block: nil
      )
    end

    it "fails with invalid parameter kind" do
      categorizer = described_class.new [%i[bogus test]]
      expectation = proc { categorizer.call [1] }

      expect(&expectation).to raise_error(ArgumentError, "Invalid parameter kind: :bogus.")
    end

    it "fails with invalid keyword argument" do
      expectation = proc { categorizer.call [1, 2, 3, "test", {a: 1}] }
      expect(&expectation).to raise_error(TypeError, %("test" is an invalid :keyreq value.))
    end
  end
end
