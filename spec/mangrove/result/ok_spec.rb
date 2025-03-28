# typed: strict
# frozen_string_literal: true

require "spec_helper"
require "mangrove/result"

RSpec.describe Mangrove::Result::Ok do
  describe "#ok_inner" do
    it "extracts inner value" do
      expect(Mangrove::Result::Ok.new(1).ok_inner).to eq 1
      expect(Mangrove::Result::Ok.new(:my_symbol).ok_inner).to eq :my_symbol
    end
  end

  describe "#unwrap!" do
    it "extracts inner value" do
      expect(Mangrove::Result::Ok.new(1).unwrap!).to eq 1
      expect(Mangrove::Result::Ok.new(:my_symbol).unwrap!).to eq :my_symbol
    end
  end

  describe "#unwrap_or_raise!" do
    it "extracts inner value" do
      expect(Mangrove::Result::Ok.new(1).unwrap_or_raise!(Exception.new)).to eq 1
      expect(Mangrove::Result::Ok.new(:my_symbol).unwrap_or_raise!(Exception.new)).to eq :my_symbol
    end
  end

  describe "#unwrap_or_raise_with!" do
    it "extracts inner value" do
      expect(Mangrove::Result::Ok.new(1).unwrap_or_raise_with!(&->(e) { Exception.new("my error: #{e}") })).to eq 1
      expect(Mangrove::Result::Ok.new(:my_symbol).unwrap_or_raise_with!(&->(e) { Exception.new("my error: #{e}") })).to eq :my_symbol
    end
  end

  describe "#unwrap_or_raise_inner!" do
    it "extracts inner value" do
      expect(Mangrove::Result::Ok.new(1).unwrap_or_raise_inner!).to eq 1
      expect(Mangrove::Result::Ok.new(:my_symbol).unwrap_or_raise_inner!).to eq :my_symbol
    end
  end

  describe "#unwrap_in" do
    it "extracts inner value" do
      expect(Mangrove::Result::Ok.new(1).unwrap_in(Mangrove::Result::CollectingContext.new)).to eq 1
      expect(Mangrove::Result::Ok.new(:my_symbol).unwrap_in(Mangrove::Result::CollectingContext.new)).to eq :my_symbol
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
      expect(Mangrove::Result::Ok.new(1).expect_with!(&->(_e) { "my expectation" })).to eq 1
      expect(Mangrove::Result::Ok.new(:my_symbol).expect_with!(&->(_e) { "my expectation" })).to eq :my_symbol
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

  describe "#map" do
    it "maps self with value returned by given block" do
      expect(Mangrove::Result::Ok.new(1).map { Mangrove::Result::Ok.new(2) }).to eq Mangrove::Result::Ok.new(2)
      expect(Mangrove::Result::Ok.new(:my_symbol).map { Mangrove::Result::Err.new(:my_new_symbol) }).to eq Mangrove::Result::Err.new(:my_new_symbol)
    end
  end

  describe "#map_wt" do
    it "maps self with value returned by given block" do
      expect(Mangrove::Result::Ok.new(1).map_wt(Integer, Symbol) { Mangrove::Result::Ok.new(2) }).to eq Mangrove::Result::Ok.new(2)
      expect(Mangrove::Result::Ok.new(:my_symbol).map_wt(Symbol, Symbol) { Mangrove::Result::Ok.new(:my_new_symbol) }).to eq Mangrove::Result::Ok.new(:my_new_symbol)
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
      expect(Mangrove::Result::Ok[Integer].new(0).map_ok_wt(Symbol) { |_| :ok }).to eq Mangrove::Result::Ok[Symbol].new(:ok)
      expect(Mangrove::Result::Ok[Integer].new(0).map_ok_wt(String) { |_| "ok" }).to eq Mangrove::Result::Ok[String].new("ok")
    end
  end

  describe "#map_err" do
    it "does not change inner value" do
      expect(Mangrove::Result::Ok.new(1).map_err { 2 }).to eq Mangrove::Result::Ok.new(1)
      expect(Mangrove::Result::Ok.new(:my_symbol).map_err { :my_new_symbol }).to eq Mangrove::Result::Ok.new(:my_symbol)
    end
  end

  describe "#map_err_wt" do
    it "does not change inner value" do
      expect(Mangrove::Result::Ok[Integer].new(0).map_err_wt(Symbol, &->(_) { :error })).to eq Mangrove::Result::Ok[Integer].new(0)
      expect(Mangrove::Result::Ok[Integer].new(1).map_err_wt(String, &->(_) { "error" })).to eq Mangrove::Result::Ok[Integer].new(1)
    end
  end

  describe "#tap_ok" do
    it "calls given block with inner value" do
      expect(Mangrove::Result::Ok.new(1).tap_ok { |i| i * 2 }).to eq Mangrove::Result::Ok.new(1)
      expect(Mangrove::Result::Ok.new(:my_symbol).tap_ok(&:to_s)).to eq Mangrove::Result::Ok.new(:my_symbol)
    end
  end

  describe "#tap_err" do
    it "calls given block with inner value" do
      # 静的に到達しないことがわかってしまって型検査に通らないので、T.let で型を指定する
      expect(T.let(Mangrove::Result::Ok.new(1), Mangrove::Result[Integer, Symbol]).tap_err(&:to_s)).to eq Mangrove::Result::Ok.new(1)
      expect(T.let(Mangrove::Result::Ok.new(:my_symbol), Mangrove::Result[Symbol, Integer]).tap_err(&:to_s)).to eq Mangrove::Result::Ok.new(:my_symbol)
    end
  end

  describe "#and" do
    it "returns other" do
      expect(Mangrove::Result::Ok[Integer].new(0).and(Mangrove::Result::Ok[String].new("ok"))).to eq Mangrove::Result::Ok[String].new("ok")
      expect(Mangrove::Result::Ok[Integer].new(0).and(Mangrove::Result::Err[Symbol].new(:err))).to eq Mangrove::Result::Err[Symbol].new(:err)
    end
  end

  describe "#and_then" do
    it "maps inner value with value returned by given block" do
      expect(Mangrove::Result::Ok[Integer].new(0).and_then { |_| Mangrove::Result.ok_wt("ok", Symbol) }).to eq Mangrove::Result::Ok[String].new("ok")
      expect(Mangrove::Result::Ok[Integer].new(0).and_then { |_| Mangrove::Result.err_wt(String, :err) }).to eq Mangrove::Result::Err[Symbol].new(:err)
    end
  end

  describe "#and_then_wt" do
    it "maps inner value with value returned by given block" do
      expect(Mangrove::Result::Ok[Integer].new(0).and_then_wt(String) { |_| Mangrove::Result.ok_wt("ok", Symbol) }).to eq Mangrove::Result::Ok[String].new("ok")
      expect(Mangrove::Result::Ok[Integer].new(0).and_then_wt(Symbol) { |_| Mangrove::Result.err_wt(Symbol, :err) }).to eq Mangrove::Result::Err[Symbol].new(:err)
    end
  end

  describe "#and_err_if" do
    let(:ok) { Mangrove::Result::Ok[Integer].new(0) }

    context "when given block returns true" do
      it "returns a Result::Err that contains the given argument" do
        expect(ok.and_err_if("my error") { |i| i == 0 }).to eq Mangrove::Result::Err[String].new("my error")
        expect(ok.and_err_if(Exception.new) { |i| i == 0 }).to eq Mangrove::Result::Err[Exception].new(Exception.new)
      end
    end

    context "when given block returns false" do
      it "returns self" do
        expect(ok.and_err_if("my error") { |i| i != 0 }).to eq ok
        expect(ok.and_err_if(Exception.new) { |i| i != 0 }).to eq ok
      end
    end
  end

  describe "#or" do
    it "returns self" do
      expect(Mangrove::Result::Ok[Integer].new(0).or(Mangrove::Result::Ok[Integer].new(1))).to eq Mangrove::Result::Ok[Integer].new(0)
      expect(Mangrove::Result::Ok[Integer].new(0).or(Mangrove::Result::Err[Symbol].new(:error))).to eq Mangrove::Result::Ok[Integer].new(0)
    end
  end

  describe "#or_else" do
    it "returns self" do
      expect(Mangrove::Result::Ok[Integer].new(0).or_else(&->(_) { Mangrove::Result.ok_wt(1, String) })).to eq Mangrove::Result::Ok[Integer].new(0)
      expect(Mangrove::Result::Ok[Integer].new(0).or_else(&->(_) { Mangrove::Result.err_wt(Integer, "error") })).to eq Mangrove::Result::Ok[Integer].new(0)
    end
  end

  describe "#or_else_wt" do
    it "returns self" do
      expect(Mangrove::Result::Ok[Integer].new(0).or_else_wt(String, &->(_) { Mangrove::Result.ok_wt(1, String) })).to eq Mangrove::Result::Ok[Integer].new(0)
      expect(Mangrove::Result::Ok[Integer].new(0).or_else_wt(String, &->(_) { Mangrove::Result.err_wt(Integer, "error") })).to eq Mangrove::Result::Ok[Integer].new(0)
    end
  end

  describe "#or_ok_if" do
    let(:ok) { Mangrove::Result::Ok[Integer].new(0) }

    context "when given block returns true" do
      it "returns self" do
        expect(ok.or_ok_if("my error") { |i| i == 0 }).to eq ok
        expect(ok.or_ok_if(Exception.new) { |i| i == 0 }).to eq ok
      end
    end

    context "when given block returns false" do
      it "returns self" do
        expect(ok.or_ok_if("my error") { |i| i != 0 }).to eq ok
        expect(ok.or_ok_if(Exception.new) { |i| i != 0 }).to eq ok
      end
    end
  end

  describe "#to_s" do
    it "includes inner value" do
      expect(Mangrove::Result::Ok.new("my inner").to_s).to include ": inner=`my inner`"
    end
  end
end
