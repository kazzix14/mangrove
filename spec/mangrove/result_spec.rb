# typed: strict
# frozen_string_literal: true

require "spec_helper"
require "mangrove/result"

RSpec.describe Mangrove::Result do
  it "declares #unwrap!" do
    expect(Mangrove::Result.instance_methods).to include :unwrap!
  end

  it "declares #unwrap_or_raise!" do
    expect(Mangrove::Result.instance_methods).to include :unwrap_or_raise!
  end

  it "declares #unwrap_or_raise_inner!" do
    expect(Mangrove::Result.instance_methods).to include :unwrap_or_raise_inner!
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

  it "declares #map" do
    expect(Mangrove::Result.instance_methods).to include :map
  end

  it "declares #map_wt" do
    expect(Mangrove::Result.instance_methods).to include :map_wt
  end

  it "declares #map_ok" do
    expect(Mangrove::Result.instance_methods).to include :map_ok
  end

  it "declares #map_err" do
    expect(Mangrove::Result.instance_methods).to include :map_err
  end

  it "declares #and" do
    expect(Mangrove::Result.instance_methods).to include :and
  end

  it "declares #and_then" do
    expect(Mangrove::Result.instance_methods).to include :and_then
  end

  it "declares #and_then_wt" do
    expect(Mangrove::Result.instance_methods).to include :and_then_wt
  end

  it "declares #and_err_if" do
    expect(Mangrove::Result.instance_methods).to include :and_err_if
  end

  it "declares #or_ok_if" do
    expect(Mangrove::Result.instance_methods).to include :or_ok_if
  end

  it "declares #or" do
    expect(Mangrove::Result.instance_methods).to include :or
  end

  it "declares #or_else" do
    expect(Mangrove::Result.instance_methods).to include :or_else
  end

  it "declares #or_else_wt" do
    expect(Mangrove::Result.instance_methods).to include :or_else_wt
  end

  it "implements .from_results" do
    expect(Mangrove::Result.methods).to include :from_results
    expect(Mangrove::Result.from_results([Mangrove::Result::Ok.new(1), Mangrove::Result::Ok.new(2), Mangrove::Result::Ok.new(3)])).to eq Mangrove::Result::Ok.new([1, 2, 3])
    expect(Mangrove::Result.from_results([Mangrove::Result::Ok.new(1), Mangrove::Result::Err.new("error 1"), Mangrove::Result::Err.new("error 2")])).to eq Mangrove::Result::Err.new(["error 1", "error 2"])
  end

  it "implements .ok" do
    expect(Mangrove::Result.methods).to include :ok
    expect(Mangrove::Result.ok(1)).to eq Mangrove::Result::Ok[Integer, String].new(1)
  end

  it "implements .ok_wt" do
    expect(Mangrove::Result.methods).to include :ok_wt
    expect(Mangrove::Result.ok_wt(1, String)).to eq Mangrove::Result::Ok[Integer, String].new(1)
  end

  it "implements .err" do
    expect(Mangrove::Result.methods).to include :err
    expect(Mangrove::Result.err(:my_value)).to eq Mangrove::Result::Err[Integer, Symbol].new(:my_value)
  end

  it "implements .err_wt" do
    expect(Mangrove::Result.methods).to include :err_wt
    expect(Mangrove::Result.err_wt(Integer, :my_value)).to eq Mangrove::Result::Err[Integer, Symbol].new(:my_value)
  end
end
