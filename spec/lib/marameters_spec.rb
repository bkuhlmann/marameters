# frozen_string_literal: true

require "spec_helper"

RSpec.describe Marameters do
  subject(:marameters) { described_class }

  include_context "with parameters"

  describe ".loader" do
    it "eager loads" do
      expectation = proc { described_class.loader.eager_load force: true }
      expect(&expectation).not_to raise_error
    end

    it "answers unique tag" do
      expect(described_class.loader.tag).to eq("marameters")
    end
  end

  describe ".categorize" do
    it "answers categorized arguments" do
      function = proc { "test" }
      arguments = [1, 2, [98, 99], {four: 4}, {five: 5}, {twenty: 20, thirty: 30}, function]

      expect(marameters.categorize(named, arguments)).to have_attributes(
        positionals: [1, 2, 98, 99],
        keywords: {four: 4, five: 5, twenty: 20, thirty: 30},
        block: function
      )
    end
  end

  describe ".of" do
    it "answers parameters" do
      parameters = marameters.of(test_module, :named).flat_map(&:to_a)
      expect(parameters).to eq(named_proof)
    end
  end

  describe ".for" do
    it "answers parameter details" do
      expect(marameters.for(named).to_a).to eq(
        [
          %i[req one],
          %i[opt two],
          %i[rest three],
          %i[keyreq four],
          %i[key five],
          %i[keyrest six],
          %i[block seven]
        ]
      )
    end
  end

  describe ".signature" do
    let :parameters do
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

    it "answers parameters" do
      expect(marameters.signature(parameters).to_s).to eq(
        "one, two = 2, *three, four:, five: 5, **six, &seven"
      )
    end
  end
end
