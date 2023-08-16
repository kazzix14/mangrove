# typed: strict
# frozen_string_literal: true

require "spec_helper"
require "mangrove/option"

RSpec.describe Mangrove::Option do
  it "declares #unwrap!" do
    expect(Mangrove::Option.instance_methods).to include :unwrap!
  end
  it "declares #expect!" do
    expect(Mangrove::Option.instance_methods).to include :expect!
  end
  it "declares #map_some" do
    expect(Mangrove::Option.instance_methods).to include :map_some
  end
  it "declares #map_none" do
    expect(Mangrove::Option.instance_methods).to include :map_none
  end
end
