# frozen_string_literal: true

module Marameters
  module Models
    # Models all parameter categories.
    Category = Data.define :positionals, :keywords, :keys, :splats, :forwards do
      def initialize positionals: %i[req opt].freeze,
                     keywords: %i[keyreq key].freeze,
                     keys: %i[keyreq key keyrest].freeze,
                     splats: %i[rest keyrest].freeze,
                     forwards: %i[rest keyrest block].freeze
        super
      end
    end
  end
end
