# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "marameters"
  spec.version = "0.0.0"
  spec.authors = ["Brooke Kuhlmann"]
  spec.email = ["brooke@alchemists.io"]
  spec.homepage = "https://www.alchemists.io/projects/marameters"
  spec.summary = "Provides method parameter introspection which is useful when metaprogramming."
  spec.license = "Hippocratic-2.1"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/bkuhlmann/marameters/issues",
    "changelog_uri" => "https://www.alchemists.io/projects/marameters/versions",
    "documentation_uri" => "https://www.alchemists.io/projects/marameters",
    "label" => "Marameters",
    "rubygems_mfa_required" => "true",
    "source_code_uri" => "https://github.com/bkuhlmann/marameters"
  }

  spec.signing_key = Gem.default_key_path
  spec.cert_chain = [Gem.default_cert_path]

  spec.required_ruby_version = "~> 3.1"
  spec.add_dependency "refinements", "~> 9.2"
  spec.add_dependency "zeitwerk", "~> 2.5"

  spec.extra_rdoc_files = Dir["README*", "LICENSE*"]
  spec.files = Dir["*.gemspec", "lib/**/*"]
end
