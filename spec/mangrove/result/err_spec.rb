# typed: strict
# frozen_string_literal: true

require "spec_helper"
require "mangrove/result"

RSpec.describe Mangrove::Result::Err do
  context "#err_inner" do
    it "extracts inner value" do
      expect(Mangrove::Result::Err.new(:my_error).err_inner).to eq :my_error
    end
  end

  context "#unwrap!" do
    it "raises ControlSignal" do
      expect { Mangrove::Result::Err.new(:my_error).unwrap! }.to raise_error(Mangrove::Result::ControlSignal)
    end
  end

  context "#expect!" do
    it "raises ControlSignal with custom message" do
      expect { Mangrove::Result::Err.new(:my_error).expect!("my expectation") }.to raise_error(Mangrove::Result::ControlSignal.new("my expectation"))
    end
  end

  context "#ok?" do
    it "returns false" do
      expect(Mangrove::Result::Err.new(:a).ok?).to eq false
    end
  end

  context "#err?" do
    it "returns true" do
      expect(Mangrove::Result::Err.new(:a).err?).to eq true
    end
  end

  context "#map_ok" do
    it "does not change inner value" do
      expect(Mangrove::Result::Err.new(:my_error).map_ok { Mangrove::Result::Ok.new(2) }).to eq Mangrove::Result::Err.new(:my_error)
      expect(Mangrove::Result::Err.new(:my_error).map_ok { Mangrove::Result::Ok.new(:my_new_error) }).to eq Mangrove::Result::Err.new(:my_error)
    end
  end

  context "#map_err" do
    it "maps inner value with value returned by given block" do
      expect(Mangrove::Result::Err.new(:my_error).map_err { Mangrove::Result::Err.new(2) }).to eq Mangrove::Result::Err.new(2)
      expect(Mangrove::Result::Err.new(:my_error).map_err { Mangrove::Result::Err.new(:my_new_error) }).to eq Mangrove::Result::Err.new(:my_new_error)
    end
  end

  context "#to_s" do
    it "includes inner value" do
      expect(Mangrove::Result::Err.new("my inner").to_s).to include ": inner=`my inner`"
    end
  end
end
