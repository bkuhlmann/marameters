# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "marameters"
  spec.version = "4.4.0"
  spec.authors = ["Brooke Kuhlmann"]
  spec.email = ["brooke@alchemists.io"]
  spec.homepage = "https://alchemists.io/projects/marameters"
  spec.summary = "A dynamic method parameter enhancer."
  spec.license = "Hippocratic-2.1"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/bkuhlmann/marameters/issues",
    "changelog_uri" => "https://alchemists.io/projects/marameters/versions",
    "homepage_uri" => "https://alchemists.io/projects/marameters",
    "funding_uri" => "https://github.com/sponsors/bkuhlmann",
    "label" => "Marameters",
    "rubygems_mfa_required" => "true",
    "source_code_uri" => "https://github.com/bkuhlmann/marameters"
  }

  spec.signing_key = Gem.default_key_path
  spec.cert_chain = [Gem.default_cert_path]

  spec.required_ruby_version = "~> 3.4"
  spec.add_dependency "refinements", "~> 13.3"
  spec.add_dependency "zeitwerk", "~> 2.7"

  spec.extra_rdoc_files = Dir["README*", "LICENSE*"]
  spec.files = Dir["*.gemspec", "lib/**/*"]
end
