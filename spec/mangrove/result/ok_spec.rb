# typed: strict
# frozen_string_literal: true

require "spec_helper"
require "mangrove/result"

RSpec.describe Mangrove::Result::Ok do
  describe "#ok_inner" do
    it "extracts inner value" do
      expect(Mangrove::Result::Ok.new(1).unwrap!).to eq 1
      expect(Mangrove::Result::Ok.new(:my_symbol).unwrap!).to eq :my_symbol
    end
  end

  describe "#unwrap!" do
    it "extracts inner value" do
      expect(Mangrove::Result::Ok.new(1).unwrap!).to eq 1
      expect(Mangrove::Result::Ok.new(:my_symbol).unwrap!).to eq :my_symbol
    end
  end

  describe "#expect!" do
    it "extracts inner value" do
      expect(Mangrove::Result::Ok.new(1).expect!("my expectation")).to eq 1
      expect(Mangrove::Result::Ok.new(:my_symbol).expect!("my expectation")).to eq :my_symbol
    end
  end

  describe "#expect_with!" do
    it "extracts inner value" do
      expect(Mangrove::Result::Ok.new(1).expect_with! { "my expectation" }).to eq 1
      expect(Mangrove::Result::Ok.new(:my_symbol).expect_with! { "my expectation" }).to eq :my_symbol
    end
  end

  describe "#ok?" do
    it "returns true" do
      expect(Mangrove::Result::Ok.new(1).ok?).to eq true
    end
  end

  describe "#err?" do
    it "returns false" do
      expect(Mangrove::Result::Ok.new(1).err?).to eq false
    end
  end

  describe "#map_ok" do
    it "maps inner value with value returned by given block" do
      expect(Mangrove::Result::Ok.new(1).map_ok { 2 }).to eq Mangrove::Result::Ok.new(2)
      expect(Mangrove::Result::Ok.new(:my_symbol).map_ok { :my_new_symbol }).to eq Mangrove::Result::Ok.new(:my_new_symbol)
    end
  end
  describe "#map_ok_wt" do
    it "maps inner value with value returned by given block" do
      expect(Mangrove::Result::Ok[Integer, Symbol].new(0).map_ok_wt(Symbol) { |_| :ok }).to eq Mangrove::Result::Ok[Symbol, Symbol].new(:ok)
      expect(Mangrove::Result::Ok[Integer, Symbol].new(0).map_ok_wt(String) { |_| "ok" }).to eq Mangrove::Result::Ok[String, Symbol].new("ok")
    end
  end

  describe "#map_err" do
    it "does not change inner value" do
      expect(Mangrove::Result::Ok.new(1).map_err { 2 }).to eq Mangrove::Result::Ok.new(1)
      expect(Mangrove::Result::Ok.new(:my_symbol).map_err { :my_new_symbol }).to eq Mangrove::Result::Ok.new(:my_symbol)
    end
  end

  describe "#map_err_wt" do
    it "maps inner value with value returned by given block" do
      expect(Mangrove::Result::Ok[Integer, Symbol].new(0).map_err_wt(Symbol) { |_| :error }).to eq Mangrove::Result::Ok[Integer, Symbol].new(0)
      expect(Mangrove::Result::Ok[Integer, Symbol].new(1).map_err_wt(String) { |_| "error" }).to eq Mangrove::Result::Ok[Integer, String].new(1)
    end
  end

  describe "#to_s" do
    it "includes inner value" do
      expect(Mangrove::Result::Ok.new("my inner").to_s).to include ": inner=`my inner`"
    end
  end
end
