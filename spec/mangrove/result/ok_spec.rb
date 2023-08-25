# typed: strict
# frozen_string_literal: true

require "spec_helper"
require "mangrove/result"

RSpec.describe Mangrove::Result::Ok do
  context "#unwrap!" do
    it "extracts inner value" do
      expect(Mangrove::Result::Ok.new(1).unwrap!).to eq 1
      expect(Mangrove::Result::Ok.new(:my_symbol).unwrap!).to eq :my_symbol
    end
  end

  context "#expect!" do
    it "extracts inner value" do
      expect(Mangrove::Result::Ok.new(1).expect!("my expectation")).to eq 1
      expect(Mangrove::Result::Ok.new(:my_symbol).expect!("my expectation")).to eq :my_symbol
    end
  end

  context "#ok?" do
    it "returns true" do
      expect(Mangrove::Result::Ok.new(1).ok?).to eq true
    end
  end

  context "#err?" do
    it "returns false" do
      expect(Mangrove::Result::Ok.new(1).err?).to eq false
    end
  end

  context "#map_ok" do
    it "maps inner value with value returned by given block" do
      expect(Mangrove::Result::Ok.new(1).map_ok { Mangrove::Result::Ok.new(2) }).to eq Mangrove::Result::Ok.new(2)
      expect(Mangrove::Result::Ok.new(:my_symbol).map_ok { Mangrove::Result::Ok.new(:my_new_symbol) }).to eq Mangrove::Result::Ok.new(:my_new_symbol)
    end
  end

  context "#map_err" do
    it "does not change inner value" do
      expect(Mangrove::Result::Ok.new(1).map_err { Mangrove::Result::Ok.new(2) }).to eq Mangrove::Result::Ok.new(1)
      expect(Mangrove::Result::Ok.new(:my_symbol).map_err { Mangrove::Result::Ok.new(:my_new_symbol) }).to eq Mangrove::Result::Ok.new(:my_symbol)
    end
  end
end
