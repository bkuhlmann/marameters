# frozen_string_literal: true

require "zeitwerk"

Zeitwerk::Loader.for_gem.setup

# Main namespace.
module Marameters
  KINDS = %i[req opt rest keyreq key keyrest block].freeze

  def self.categorize(parameters, arguments) = Categorizer.new(parameters).call(arguments)

  def self.of(...) = Probe.of(...)

  def self.probe(...) = Probe.new(...)

  def self.signature(...) = Signature.new(...)
end
