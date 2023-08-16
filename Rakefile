# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

task :check do
  system("bundle exec ordinare --check") &&
    system("bundle exec rubocop -DESP") &&
    system("bundle exec tapioca check-shims") &&
    system("bundle exec srb typecheck") &&
    system("bundle exec rspec -f d")
end

task default: :check
