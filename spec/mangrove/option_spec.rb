# typed: strict
# frozen_string_literal: true

require "spec_helper"
require "mangrove/option"

RSpec.describe Mangrove::Option do
  it "declares #unwrap_or" do
    expect(Mangrove::Option.instance_methods).to include :unwrap_or
  end

  it "declares #unwrap!" do
    expect(Mangrove::Option.instance_methods).to include :unwrap!
  end

  it "declares #expect!" do
    expect(Mangrove::Option.instance_methods).to include :expect!
  end

  it "declares #expect!" do
    expect(Mangrove::Option.instance_methods).to include :expect_with!
  end

  it "declares #some?" do
    expect(Mangrove::Option.instance_methods).to include :some?
  end

  it "declares #none?" do
    expect(Mangrove::Option.instance_methods).to include :none?
  end

  it "declares #map_some" do
    expect(Mangrove::Option.instance_methods).to include :map_some
  end

  it "declares #map_none" do
    expect(Mangrove::Option.instance_methods).to include :map_none
  end

  it "declares #transpose" do
    expect(Mangrove::Option.instance_methods).to include :transpose
  end

  it "implements .from_nilable" do
    expect(Mangrove::Option.methods).to include :from_nilable
    expect(Mangrove::Option.from_nilable(1)).to eq Mangrove::Option::Some.new(1)
    expect(Mangrove::Option.from_nilable(nil)).to eq Mangrove::Option::None.new
  end
end
