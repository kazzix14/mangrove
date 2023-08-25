# typed: strict
# frozen_string_literal: true

require "spec_helper"
require "mangrove/result"

RSpec.describe Mangrove::Result do
  it "declares #unwrap!" do
    expect(Mangrove::Result.instance_methods).to include :unwrap!
  end

  it "declares #expect!" do
    expect(Mangrove::Result.instance_methods).to include :expect!
  end

  it "declares #ok?" do
    expect(Mangrove::Result.instance_methods).to include :ok?
  end

  it "declares #err?" do
    expect(Mangrove::Result.instance_methods).to include :err?
  end

  it "declares #map_some" do
    expect(Mangrove::Result.instance_methods).to include :map_ok
  end

  it "declares #map_none" do
    expect(Mangrove::Result.instance_methods).to include :map_err
  end
end
