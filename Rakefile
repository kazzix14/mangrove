# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

task(:check) {
  system("bundle exec ordinare --check") &&
    system("bundle exec rubocop -DESP") &&
    system("bundle exec tapioca check-shims") &&
    system("bundle exec srb typecheck") &&
    system("bundle exec rspec -f d") &&
    # check doc version
    system(
      <<~SHELL
        gem_version=`bundle info mangrove | grep -o '[0-9]\\+\\.[0-9]\\+\\.[0-9]\\+'`
        doc_version=`grep 'VERSION =' docs/Mangrove.html -A 5 | grep -o '[0-9]\\+\\.[0-9]\\+\\.[0-9]\\+'`

        if [ "$gem_version" = "$doc_version" ]; then
          exit 0
        else
          exit 1
        fi
      SHELL
    )
}

task default: :check
