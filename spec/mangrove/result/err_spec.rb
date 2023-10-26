# typed: strict
# frozen_string_literal: true

require "spec_helper"
require "mangrove/result"

RSpec.describe Mangrove::Result::Err do
  describe "#err_inner" do
    it "extracts inner value" do
      expect(Mangrove::Result::Err.new(:my_error).err_inner).to eq :my_error
    end
  end

  describe "#unwrap!" do
    it "raises ControlSignal" do
      expect { Mangrove::Result::Err.new(:my_error).unwrap! }.to raise_error(Mangrove::Result::ControlSignal)
    end
  end

  describe "#expect!" do
    it "raises ControlSignal with custom message" do
      expect { Mangrove::Result::Err.new(:my_error).expect!("my expectation") }.to raise_error(Mangrove::Result::ControlSignal.new("my expectation"))
    end
  end

  describe "#expect_with!" do
    it "raises ControlSignal with custom message generated by passed block" do
      expect { Mangrove::Result::Err.new(:my_error).expect_with! { "my expectation" } }.to raise_error(Mangrove::Result::ControlSignal.new("my expectation"))
    end
  end

  describe "#ok?" do
    it "returns false" do
      expect(Mangrove::Result::Err.new(:a).ok?).to eq false
    end
  end

  describe "#err?" do
    it "returns true" do
      expect(Mangrove::Result::Err.new(:a).err?).to eq true
    end
  end

  describe "#map_ok" do
    it "does not change inner value" do
      expect(Mangrove::Result::Err.new(:my_error).map_ok { 2 }).to eq Mangrove::Result::Err.new(:my_error)
      expect(Mangrove::Result::Err.new(:my_error).map_ok { :my_new_error }).to eq Mangrove::Result::Err.new(:my_error)
    end
  end

  describe "#map_ok_wt" do
    it "does not change inner value" do
      expect(Mangrove::Result::Err[Integer, Symbol].new(:error).map_ok_wt(Symbol) { |_| :ok }).to eq Mangrove::Result::Err[Integer, Symbol].new(:error)
      expect(Mangrove::Result::Err[Integer, Symbol].new(:error).map_ok_wt(String) { |_| "ok" }).to eq Mangrove::Result::Err[Integer, Symbol].new(:error)
    end
  end

  describe "#map_err" do
    it "maps inner value with value returned by given block" do
      expect(Mangrove::Result::Err.new(:my_error).map_err { 2 }).to eq Mangrove::Result::Err.new(2)
      expect(Mangrove::Result::Err.new(:my_error).map_err { :my_new_error }).to eq Mangrove::Result::Err.new(:my_new_error)
    end
  end

  describe "#map_err_wt" do
    it "maps inner value with value returned by given block" do
      expect(Mangrove::Result::Err[Integer, Symbol].new(:my_error).map_err_wt(Integer) { |_| 123 }).to eq Mangrove::Result::Err[Integer, Integer].new(123)
      expect(Mangrove::Result::Err[Integer, Symbol].new(:my_error).map_err_wt(String) { |_| "error" }).to eq Mangrove::Result::Err[Integer, String].new("error")
    end
  end

  describe "#to_s" do
    it "includes inner value" do
      expect(Mangrove::Result::Err.new("my inner").to_s).to include ": inner=`my inner`"
    end
  end
end
