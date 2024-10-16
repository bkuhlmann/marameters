# frozen_string_literal: true

require "spec_helper"

RSpec.describe Marameters::Models::Category do
  subject(:model) { described_class.new }

  describe "#initialize" do
    it "answers default attributes" do
      expect(model).to have_attributes(
        positionals: %i[req opt].freeze,
        keywords: %i[keyreq key].freeze,
        keys: %i[keyreq key keyrest].freeze,
        splats: %i[rest keyrest].freeze,
        forwards: %i[rest keyrest block].freeze
      )
    end
  end
end
