# typed: strict
# frozen_string_literal: true

require "simplecov"
require "rspec/sorbet"

SimpleCov.start {
  T.bind(self, T.untyped)

  add_filter "/spec/"

  enable_coverage :branch
  primary_coverage :branch
}

require "mangrove"
