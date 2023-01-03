# frozen_string_literal: true

module Marameters
  # Captures arguments, by category, for message splatting.
  Splat = Struct.new :positionals, :keywords, :block do
    def initialize(positionals: [], keywords: {}, block: nil) = super
  end
end
