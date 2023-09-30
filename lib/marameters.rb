# frozen_string_literal: true

require "zeitwerk"

Zeitwerk::Loader.new.then do |loader|
  loader.tag = File.basename __FILE__, ".rb"
  loader.push_dir __dir__
  loader.setup
end

# Main namespace.
module Marameters
  def self.loader(registry = Zeitwerk::Registry) = registry.loader_for __FILE__

  def self.categorize(parameters, arguments) = Categorizer.new(parameters).call(arguments)

  def self.of(...) = Probe.of(...)

  def self.for(...) = Probe.new(...)

  def self.signature(...) = Signature.new(...)
end
