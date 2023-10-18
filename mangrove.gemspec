# frozen_string_literal: true

require_relative "lib/mangrove/version"

Gem::Specification.new { |spec|
  spec.name = "mangrove"
  spec.version = Mangrove::VERSION
  spec.authors = ["Kazuma Murata"]
  spec.email = ["kazzix14@gmail.com"]
  spec.licenses = ["MIT"]

  spec.summary = "Type Utility for Ruby."
  spec.description = "Type Utility for Ruby."
  spec.homepage = "https://github.com/kazzix14/mangrove"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/kazzix14/mangrove"
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) {
    `git ls-files -z`.split("\x0").reject { |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    }
  }
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "sorbet-runtime"

  # Utility
  spec.add_dependency "method_source", "~> 1.0"

  # Parser
  spec.add_dependency "parser", "~> 3.2"
  spec.add_dependency "unparser", "~> 0.6.8"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
}
