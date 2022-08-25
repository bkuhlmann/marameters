# frozen_string_literal: true

module Marameters
  # Captures arguments, by category, for message splatting.
  Splat = Struct.new :positionals, :keywords, :block, keyword_init: true do
    def initialize *arguments
      super

      self[:positionals] ||= []
      self[:keywords] ||= {}
    end
  end
end
