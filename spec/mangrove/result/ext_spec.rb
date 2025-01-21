# typed: ignore
# frozen_string_literal: true

require "spec_helper"

RSpec.describe Mangrove::Result::Ext do
  describe "#in_ok" do
    it "wraps the value in Result::Ok" do
      expect("test".in_ok).to eq(Mangrove::Result::Ok.new("test"))
      expect(42.in_ok).to eq(Mangrove::Result::Ok.new(42))
      expect([1, 2, 3].in_ok).to eq(Mangrove::Result::Ok.new([1, 2, 3]))
      expect({ a: 1 }.in_ok).to eq(Mangrove::Result::Ok.new({ a: 1 }))
      expect(nil.in_ok).to eq(Mangrove::Result::Ok.new(nil))
    end
  end

  describe "#in_err" do
    it "wraps the value in Result::Err" do
      expect("error message".in_err).to eq(Mangrove::Result::Err.new("error message"))
      expect(42.in_err).to eq(Mangrove::Result::Err.new(42))
      expect([1, 2, 3].in_err).to eq(Mangrove::Result::Err.new([1, 2, 3]))
      expect({ a: 1 }.in_err).to eq(Mangrove::Result::Err.new({ a: 1 }))
      expect(nil.in_err).to eq(Mangrove::Result::Err.new(nil))
    end
  end
end
