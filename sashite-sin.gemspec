# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name                   = "sashite-sin"
  spec.version                = ::File.read("VERSION.semver").chomp
  spec.author                 = "Cyril Kato"
  spec.email                  = "contact@cyril.email"
  spec.summary                = "SIN (Style Identifier Notation) implementation for Ruby with immutable identifier objects"
  spec.description            = "SIN (Style Identifier Notation) implementation for Ruby. Provides a rule-agnostic format for identifying player styles in abstract strategy board games with immutable identifier objects and functional programming principles."
  spec.homepage               = "https://github.com/sashite/sin.rb"
  spec.license                = "Apache-2.0"
  spec.files                  = ::Dir["LICENSE", "README.md", "lib/**/*"]
  spec.required_ruby_version  = ">= 3.2.0"

  spec.metadata = {
    "bug_tracker_uri"       => "https://github.com/sashite/sin.rb/issues",
    "documentation_uri"     => "https://rubydoc.info/github/sashite/sin.rb/main",
    "homepage_uri"          => "https://github.com/sashite/sin.rb",
    "source_code_uri"       => "https://github.com/sashite/sin.rb",
    "specification_uri"     => "https://sashite.dev/specs/sin/1.0.0/",
    "wiki_uri"              => "https://sashite.dev/specs/sin/1.0.0/examples/",
    "funding_uri"           => "https://github.com/sponsors/sashite",
    "rubygems_mfa_required" => "true"
  }
end
