# typed: strict
# frozen_string_literal: true

require "spec_helper"

RSpec.describe Mangrove do
  it "has a version number" do
    expect(Mangrove::VERSION).not_to be nil
  end
end
