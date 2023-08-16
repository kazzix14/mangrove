# typed: strict
# frozen_string_literal: true

require "spec_helper"
require "mangrove/option"

RSpec.describe Mangrove::Option::Some do
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

  context "#map_some" do
    it "maps inner value with value returned by given block" do
      expect(Mangrove::Option::Some.new(1).map_some { Mangrove::Option::Some.new(2) }).to eq Mangrove::Option::Some.new(2)
      expect(Mangrove::Option::Some.new(:my_symbol).map_some { Mangrove::Option::Some.new(:my_new_symbol) }).to eq Mangrove::Option::Some.new(:my_new_symbol)
    end
  end

  context "#map_none" do
    it "does not change inner value" do
      expect(Mangrove::Option::Some.new(1).map_none { Mangrove::Option::Some.new(2) }).to eq Mangrove::Option::Some.new(1)
      expect(Mangrove::Option::Some.new(:my_symbol).map_none { Mangrove::Option::Some.new(:my_new_symbol) }).to eq Mangrove::Option::Some.new(:my_symbol)
    end
  end
end
