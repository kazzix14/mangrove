# frozen_string_literal: true

require_relative "lib/mangrove/version"

Gem::Specification.new { |spec|
  spec.name = "mangrove"
  spec.version = Mangrove::VERSION
  spec.authors = ["Kazuma Murata"]
  spec.email = ["kazzix14@gmail.com"]
  spec.licenses = ["MIT"]

  spec.summary = "Toolkit for leveraging Sorbet's type system."
  spec.description = "Mangrove is a Ruby Gem designed to be the definitive toolkit for leveraging Sorbet's type system in Ruby applications. It's designed to offer a robust, statically-typed experience, focusing on solid types, a functional programming style, and an interface-driven approach. Mangrove has `Result`, `Option` and `Algebraic Data Type` currently."
  spec.homepage = "https://github.com/kazzix14/mangrove"
  spec.required_ruby_version = ">= 3.1.2"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["documentation_uri"] = "https://kazzix14.github.io/mangrove/docs/"
  spec.metadata["source_code_uri"] = "https://github.com/kazzix14/mangrove"
  spec.metadata["rubygems_mfa_required"] = "true"

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
  spec.require_paths = %w[lib rbi]

  spec.add_dependency "sorbet-runtime", ">= 0.5.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
}
