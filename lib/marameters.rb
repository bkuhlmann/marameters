# frozen_string_literal: true

require "zeitwerk"

Zeitwerk::Loader.for_gem.setup

# Main namespace.
module Marameters
  KINDS = %i[req opt rest keyreq key keyrest block].freeze
end
