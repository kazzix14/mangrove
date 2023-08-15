# frozen_string_literal: true

require "mangrove"

RSpec.describe Mangrove do
  it "has a version number" do
    expect(Mangrove::VERSION).not_to be nil
  end
end
