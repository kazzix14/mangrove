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

  it "declares #expect_with!" do
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

  it "implements .from_results" do
    expect(Mangrove::Result.methods).to include :from_results
    expect(Mangrove::Result.from_results([Mangrove::Result::Ok.new(1), Mangrove::Result::Ok.new(2), Mangrove::Result::Ok.new(3)])).to eq Mangrove::Result::Ok.new([1, 2, 3])
    expect(Mangrove::Result.from_results([Mangrove::Result::Ok.new(1), Mangrove::Result::Err.new("error 1"), Mangrove::Result::Err.new("error 2")])).to eq Mangrove::Result::Err.new(["error 1", "error 2"])
  end
end
