# frozen_string_literal: true

module Marameters
  module Models
    # Models arguments, by category, for forwarding.
    Forward = Struct.new :positionals, :keywords, :block do
      def initialize(positionals: [], keywords: {}, block: nil) = super
    end
  end
end
