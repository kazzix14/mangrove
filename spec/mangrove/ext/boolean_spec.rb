# typed: strict
# frozen_string_literal: true

require "spec_helper"
require "mangrove/ext/boolean"

RSpec.describe "TrueClass#into_result" do
  T.bind(self, T.untyped)

  it "declares #unwrap!" do
    T.bind(self, T.untyped)

    expect(true.into_result).to eq Mangrove::Result::Ok.new(true)
  end

  it "declares #unwrap!" do
    T.bind(self, T.untyped)

    expect(true.into_result(1)).to eq Mangrove::Result::Ok.new(1)
  end

  it "declares #unwrap!" do
    T.bind(self, T.untyped)

    expect(true.into_result(1, 2)).to eq Mangrove::Result::Ok.new(1)
  end
end

RSpec.describe "FalseClass#into_result" do
  T.bind(self, T.untyped)

  it "declares #unwrap!" do
    T.bind(self, T.untyped)

    expect(false.into_result).to eq Mangrove::Result::Err.new(false)
  end

  it "declares #unwrap!" do
    T.bind(self, T.untyped)

    expect(false.into_result(1)).to eq Mangrove::Result::Err.new(1)
  end

  it "declares #unwrap!" do
    T.bind(self, T.untyped)

    expect(false.into_result(1, 2)).to eq Mangrove::Result::Err.new(2)
  end
end
