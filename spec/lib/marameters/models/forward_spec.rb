# frozen_string_literal: true

require "spec_helper"

RSpec.describe Marameters::Models::Forward do
  subject(:model) { described_class.new }

  describe "#initialize" do
    it "answers default attributes" do
      expect(model).to have_attributes(positionals: [], keywords: {}, block: nil)
    end
  end
end
