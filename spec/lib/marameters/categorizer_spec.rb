# frozen_string_literal: true

require "spec_helper"

RSpec.describe Marameters::Categorizer do
  subject(:categorizer) { described_class.new named }

  include_context "with parameters"

  describe "#call" do
    let(:function) { proc { "test" } }
    let(:maximum) { [1, 2, [98, 99], {four: 4}, {five: 5}, {twenty: 20, thirty: 30}, function] }

    it "answers empty arguments when given empty arguments" do
      expect(categorizer.call([])).to have_attributes(positionals: [], keywords: {}, block: nil)
    end

    it "answers empty arguments when no parameters exist for arguments" do
      categorizer = described_class.new none

      expect(categorizer.call([1, 2, 3])).to have_attributes(
        positionals: [],
        keywords: {},
        block: nil
      )
    end

    it "casts an argument as an array if not already an array" do
      expect(categorizer.call(1)).to have_attributes(positionals: [1], keywords: {}, block: nil)
    end

    it "clears and rebuilds arguments when called multiple times" do
      arguments = [1, 2, nil, {four: 4}]
      categorizer.call arguments

      expect(categorizer.call(arguments)).to have_attributes(
        positionals: [1, 2],
        keywords: {four: 4},
        block: nil
      )
    end

    it "answers maximum forwarded arguments" do
      categorizer = Module.new { def test(...) = super }
                          .instance_method(:test)
                          .parameters
                          .then { |parameters| described_class.new parameters }

      arguments = [[1, 2, 98, 99], {four: 4, five: 5, twenty: 20, thirty: 30}, function]

      expect(categorizer.call(arguments)).to have_attributes(
        positionals: [1, 2, 98, 99],
        keywords: {four: 4, five: 5, twenty: 20, thirty: 30},
        block: function
      )
    end

    it "answers only forwarded positional arguments" do
      categorizer = Module.new { def test(...) = super }
                          .instance_method(:test)
                          .parameters
                          .then { |parameters| described_class.new parameters }

      arguments = [[1, 2, 98, 99]]

      expect(categorizer.call(arguments)).to have_attributes(
        positionals: [1, 2, 98, 99],
        keywords: {},
        block: nil
      )
    end

    it "answers only forwarded keyword arguments" do
      categorizer = Module.new { def test(...) = super }
                          .instance_method(:test)
                          .parameters
                          .then { |parameters| described_class.new parameters }

      arguments = [nil, {four: 4, five: 5, twenty: 20}]

      expect(categorizer.call(arguments)).to have_attributes(
        positionals: [],
        keywords: {four: 4, five: 5, twenty: 20},
        block: nil
      )
    end

    it "answers only forwarded block argument" do
      categorizer = Module.new { def test(...) = super }
                          .instance_method(:test)
                          .parameters
                          .then { |parameters| described_class.new parameters }

      arguments = [nil, nil, function]

      expect(categorizer.call(arguments)).to have_attributes(
        positionals: [],
        keywords: {},
        block: function
      )
    end

    it "answers maximum bare splatted arguments" do
      categorizer = Module.new { def test(*, **, &) = super }
                          .instance_method(:test)
                          .parameters
                          .then { |parameters| described_class.new parameters }

      arguments = [[1, 2, 98, 99], {four: 4, five: 5, twenty: 20}, function]

      expect(categorizer.call(arguments)).to have_attributes(
        positionals: [1, 2, 98, 99],
        keywords: {four: 4, five: 5, twenty: 20},
        block: function
      )
    end

    it "answers only bare splatted positional arguments" do
      categorizer = Module.new { def test(*, **, &) = super }
                          .instance_method(:test)
                          .parameters
                          .then { |parameters| described_class.new parameters }

      arguments = [[1, 2, 98, 99]]

      expect(categorizer.call(arguments)).to have_attributes(
        positionals: [1, 2, 98, 99],
        keywords: {},
        block: function
      )
    end

    it "answers only bare splatted keyword arguments" do
      categorizer = Module.new { def test(*, **, &) = super }
                          .instance_method(:test)
                          .parameters
                          .then { |parameters| described_class.new parameters }

      arguments = [nil, {four: 4, five: 5, twenty: 20}]

      expect(categorizer.call(arguments)).to have_attributes(
        positionals: [],
        keywords: {four: 4, five: 5, twenty: 20},
        block: function
      )
    end

    it "answers maximum name splatted arguments" do
      categorizer = Module.new { def test(*one, **two, &block) = super one, two, yield(block) }
                          .instance_method(:test)
                          .parameters
                          .then { |parameters| described_class.new parameters }

      arguments = [[1, 2, 98, 99], {four: 4, five: 5, twenty: 20}, function]

      expect(categorizer.call(arguments)).to have_attributes(
        positionals: [1, 2, 98, 99],
        keywords: {four: 4, five: 5, twenty: 20},
        block: function
      )
    end

    it "answers only name splatted positional arguments" do
      categorizer = Module.new { def test(*one, **two, &block) = super one, two, yield(block) }
                          .instance_method(:test)
                          .parameters
                          .then { |parameters| described_class.new parameters }

      arguments = [[1, 2, 98, 99]]

      expect(categorizer.call(arguments)).to have_attributes(
        positionals: [1, 2, 98, 99],
        keywords: {},
        block: nil
      )
    end

    it "answers only name splatted keyword arguments" do
      categorizer = Module.new { def test(*one, **two, &block) = super one, two, yield(block) }
                          .instance_method(:test)
                          .parameters
                          .then { |parameters| described_class.new parameters }

      arguments = [nil, {four: 4, five: 5, twenty: 20}]

      expect(categorizer.call(arguments)).to have_attributes(
        positionals: [],
        keywords: {four: 4, five: 5, twenty: 20},
        block: nil
      )
    end

    it "answers hash argument for single splat parameter" do
      categorizer = Module.new { def test(*) = super }
                          .instance_method(:test)
                          .parameters
                          .then { |parameters| described_class.new parameters }

      arguments = [{a: 1}]

      expect(categorizer.call(arguments)).to have_attributes(
        positionals: [{a: 1}],
        keywords: {},
        block: nil
      )
    end

    it "answers hash argument for bare double splat parameter" do
      categorizer = Module.new { def test(**) = super }
                          .instance_method(:test)
                          .parameters
                          .then { |parameters| described_class.new parameters }

      arguments = [{four: 4}]

      expect(categorizer.call(arguments)).to have_attributes(
        positionals: [],
        keywords: {four: 4},
        block: nil
      )
    end

    it "answers empty keyword arguments for nokey parameter" do
      categorizer = Module.new { def test(**nil) = super }
                          .instance_method(:test)
                          .parameters
                          .then { |parameters| described_class.new parameters }

      arguments = [{four: 4}]

      expect(categorizer.call(arguments)).to have_attributes(
        positionals: [],
        keywords: {},
        block: nil
      )
    end

    it "answers arguments where keywords are empty for nokey parameter" do
      categorizer = Module.new { def test(one, **nil, &) = super }
                          .instance_method(:test)
                          .parameters
                          .then { |parameters| described_class.new parameters }

      arguments = [1, {four: 4}, function]

      expect(categorizer.call(arguments)).to have_attributes(
        positionals: [1],
        keywords: {},
        block: function
      )
    end

    it "answers block argument for anonymous block parameter" do
      categorizer = Module.new { def test(&) = super }
                          .instance_method(:test)
                          .parameters
                          .then { |parameters| described_class.new parameters }

      expect(categorizer.call(maximum)).to have_attributes(
        positionals: [],
        keywords: {},
        block: function
      )
    end

    it "answers block argument for named block parameter" do
      categorizer = Module.new { def test(&block) = super yield(block) }
                          .instance_method(:test)
                          .parameters
                          .then { |parameters| described_class.new parameters }

      expect(categorizer.call(maximum)).to have_attributes(
        positionals: [],
        keywords: {},
        block: function
      )
    end

    it "answers minimum arguments" do
      expect(categorizer.call([1, 2, nil, {four: 4}])).to have_attributes(
        positionals: [1, 2],
        keywords: {four: 4},
        block: nil
      )
    end

    it "answers minimum arguments with nils filled to last position" do
      arguments = [nil, nil, nil, {four: 4}, nil, nil, function]

      expect(categorizer.call(arguments)).to have_attributes(
        positionals: [nil, nil],
        keywords: {four: 4},
        block: function
      )
    end

    it "answers minimum arguments when requirements are filled to last position" do
      arguments = [:a, nil, nil, {four: 4}, nil, nil, function]

      expect(categorizer.call(arguments)).to have_attributes(
        positionals: [:a, nil],
        keywords: {four: 4},
        block: function
      )
    end

    it "answers maximum arguments" do
      expect(categorizer.call(maximum)).to have_attributes(
        positionals: [1, 2, 98, 99],
        keywords: {four: 4, five: 5, twenty: 20, thirty: 30},
        block: function
      )
    end

    it "fails with invalid parameter kind" do
      categorizer = described_class.new [%i[bogus test]]
      expectation = proc { categorizer.call [1] }

      expect(&expectation).to raise_error(ArgumentError, "Invalid parameter kind: :bogus.")
    end

    it "fails with invalid keyword argument" do
      expectation = proc { categorizer.call [1, 2, 3, "test"] }
      expect(&expectation).to raise_error(TypeError, %("test" is an invalid :keyreq value.))
    end
  end
end
