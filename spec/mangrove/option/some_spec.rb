# typed: false
# frozen_string_literal: true

require "spec_helper"
require "mangrove/option"

RSpec.describe Mangrove::Option::Some do
  context "#unwrap_or" do
    it "returns inner value" do
      expect(Mangrove::Option::Some.new(1).unwrap_or(2)).to eq 1
    end
  end

  context "#unwrap!" do
    it "extracts inner value" do
      expect(Mangrove::Option::Some.new(1).unwrap!).to eq 1
      expect(Mangrove::Option::Some.new(:my_symbol).unwrap!).to eq :my_symbol
    end
  end

  context "#expect!" do
    it "extracts inner value" do
      expect(Mangrove::Option::Some.new(1).expect!("my expectation")).to eq 1
      expect(Mangrove::Option::Some.new(:my_symbol).expect!("my expectation")).to eq :my_symbol
    end
  end

  context "#expect_with!" do
    it "extracts inner value" do
      expect(Mangrove::Option::Some.new(1).expect_with! { "my expectation" }).to eq 1
      expect(Mangrove::Option::Some.new(:my_symbol).expect_with! { "my expectation" }).to eq :my_symbol
    end
  end

  context "#some?" do
    it "returns true" do
      expect(Mangrove::Option::Some.new(1).some?).to eq true
    end
  end

  context "#none?" do
    it "returns false" do
      expect(Mangrove::Option::Some.new(1).none?).to eq false
    end
  end

  context "#map" do
    it "maps inner value with value returned by given block" do
      expect(Mangrove::Option::Some.new(1).map { Mangrove::Option::Some.new(2) }).to eq Mangrove::Option::Some.new(2)
      expect(Mangrove::Option::Some.new(:my_symbol).map { Mangrove::Option::Some.new(:my_new_symbol) }).to eq Mangrove::Option::Some.new(:my_new_symbol)
    end
  end

  context "#or" do
    it "does not change inner value" do
      expect(Mangrove::Option::Some.new(1).or(Mangrove::Option::Some.new(2))).to eq Mangrove::Option::Some.new(1)
      expect(Mangrove::Option::Some.new(:my_symbol).or(Mangrove::Option::Some.new(:my_new_symbol))).to eq Mangrove::Option::Some.new(:my_symbol)
    end
  end

  context "#transpose" do
    it "returns Result::Ok inheriting the inner" do
      expect(Mangrove::Option::Some.new(:my_ok).transpose(:my_err)).to eq Mangrove::Result::Ok.new(:my_ok)
    end
  end
end
