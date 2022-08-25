# frozen_string_literal: true

require "spec_helper"

RSpec.describe Marameters::Splat do
  subject(:gist) { described_class.new }

  describe "#initialize" do
    it "answers default attributes" do
      expect(gist).to have_attributes(positionals: [], keywords: {}, block: nil)
    end
  end
end
