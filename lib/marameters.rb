# frozen_string_literal: true

require "zeitwerk"

Zeitwerk::Loader.for_gem.setup

# Main namespace.
module Marameters
  def self.categorize(parameters, arguments) = Categorizer.new(parameters).call(arguments)

  def self.of(...) = Probe.of(...)

  def self.for(...) = Probe.new(...)

  def self.signature(...) = Signature.new(...)
end
