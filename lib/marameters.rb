# frozen_string_literal: true

require "zeitwerk"

Zeitwerk::Loader.new.then do |loader|
  loader.tag = File.basename __FILE__, ".rb"
  loader.push_dir __dir__
  loader.setup
end

# Main namespace.
module Marameters
  KINDS = %i[req opt rest nokey keyreq key keyrest block].freeze

  def self.loader registry = Zeitwerk::Registry
    @loader ||= registry.loaders.find { |loader| loader.tag == File.basename(__FILE__, ".rb") }
  end

  def self.categorize(parameters, arguments) = Categorizer.new.call parameters, arguments

  def self.of(...) = Probe.of(...)

  def self.for(...) = Probe.new(...)

  def self.signature(...) = Signature.new(...)
end
