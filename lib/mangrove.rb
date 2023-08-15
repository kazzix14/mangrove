# typed: strict
# frozen_string_literal: true

require_relative "mangrove/version"

# Mangrove
module Mangrove
  extend T::Sig

  class Error < StandardError; end
  # Your code goes here...

  sig { void }
  def my_method; end
end
