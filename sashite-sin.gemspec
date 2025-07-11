# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name    = "sashite-sin"
  spec.version = ::File.read("VERSION.semver").chomp
  spec.author  = "Cyril Kato"
  spec.email   = "contact@cyril.email"
  spec.summary = "SIN (Style Identifier Notation) implementation for Ruby with immutable identifier objects"

  spec.description = <<~DESC
    SIN (Style Identifier Notation) provides a rule-agnostic format for identifying styles
    in abstract strategy board games. This gem implements the SIN Specification v1.0.0 with
    a modern Ruby interface featuring immutable identifier objects and functional programming
    principles. SIN uses single ASCII letters with case-based side encoding (A-Z for first player,
    a-z for second player), enabling clear distinction between different style families in
    multi-style gaming environments. Perfect for cross-style matches, game engines, and hybrid
    gaming systems requiring compact style identification with enhanced collision resolution.
  DESC

  spec.homepage               = "https://github.com/sashite/sin.rb"
  spec.license                = "MIT"
  spec.files                  = ::Dir["LICENSE.md", "README.md", "lib/**/*"]
  spec.required_ruby_version  = ">= 3.2.0"

  spec.metadata = {
    "bug_tracker_uri"       => "https://github.com/sashite/sin.rb/issues",
    "documentation_uri"     => "https://rubydoc.info/github/sashite/sin.rb/main",
    "homepage_uri"          => "https://github.com/sashite/sin.rb",
    "source_code_uri"       => "https://github.com/sashite/sin.rb",
    "specification_uri"     => "https://sashite.dev/specs/sin/1.0.0/",
    "rubygems_mfa_required" => "true"
  }
end
