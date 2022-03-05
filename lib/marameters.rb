# frozen_string_literal: true

require "zeitwerk"

Zeitwerk::Loader.for_gem.setup

# Main namespace.
module Marameters
  TRANSFORMER = lambda do |parameters, pattern|
    parameters.select { |kind, _name| pattern.include? kind }
              .reduce({}) { |collection, (kind, name)| collection.merge kind => name }
  end
end
