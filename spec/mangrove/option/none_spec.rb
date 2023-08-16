# typed: strict
# frozen_string_literal: true

require "spec_helper"
require "mangrove/option"

RSpec.describe Mangrove::Option::None do
  context "#unwrap!" do
    it "raises ControlSignal" do
      expect { Mangrove::Option::None.new.unwrap! }.to raise_error(Mangrove::Option::ControlSignal)
    end
  end

  context "#expect!" do
    it "raises ControlSignal with custom message" do
      expect { Mangrove::Option::None.new.expect!("my expectation") }.to raise_error(Mangrove::Option::ControlSignal.new(Mangrove::Result::Err.new("my expectation")))
    end
  end

  context "#map_some" do
    it "does not change inner value" do
      expect(Mangrove::Option::None.new.map_some { Mangrove::Option::Some.new(2) }).to eq Mangrove::Option::None.new
      expect(Mangrove::Option::None.new.map_some { Mangrove::Option::Some.new(:my_new_symbol) }).to eq Mangrove::Option::None.new
    end
  end

  context "#map_none" do
    it "maps inner value with value returned by given block" do
      expect(Mangrove::Option::None.new.map_none { Mangrove::Option::Some.new(2) }).to eq Mangrove::Option::Some.new(2)
      expect(Mangrove::Option::None.new.map_none { Mangrove::Option::Some.new(:my_new_symbol) }).to eq Mangrove::Option::Some.new(:my_new_symbol)
    end
  end
end
