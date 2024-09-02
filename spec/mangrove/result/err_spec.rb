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

  describe "#unwrap_or_raise!" do
    it "raises given exception" do
      expect { Mangrove::Result::Err.new(:my_error).unwrap_or_raise!(Exception.new("my error")) }.to raise_error(Exception, "my error")
    end
  end

  describe "#unwrap_or_raise_with!" do
    it "raises an exception that given block returns" do
      expect { Mangrove::Result::Err.new(:my_error).unwrap_or_raise_with! { |e| Exception.new("my error: #{e}") } }.to raise_error(Exception, "my error: my_error")
    end
  end

  describe "#unwrap_or_raise_inner!" do
    it "raises err inner" do
      expect { Mangrove::Result::Err.new(Exception.new("my error")).unwrap_or_raise_inner! }.to raise_error(Exception, "my error")
    end
  end

  describe "#expect!" do
    it "raises ControlSignal with custom message" do
      expect { Mangrove::Result::Err.new(:my_error).expect!("my expectation") }.to raise_error(Mangrove::Result::ControlSignal.new("my expectation"))
    end
  end

  describe "#expect_with!" do
    it "raises ControlSignal with custom message generated by passed block" do
      expect { Mangrove::Result::Err.new(:my_error).expect_with! { |e| "my expectation: #{e}" } }.to raise_error(Mangrove::Result::ControlSignal.new("my expectation: my_error"))
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

  describe "#map" do
    it "maps self with value returned by given block" do
      expect(Mangrove::Result::Err.new(1).map { Mangrove::Result::Ok.new(2) }).to eq Mangrove::Result::Ok.new(2)
      expect(Mangrove::Result::Err.new(:my_symbol).map { Mangrove::Result::Err.new(:my_new_symbol) }).to eq Mangrove::Result::Err.new(:my_new_symbol)
    end
  end

  describe "#map_wt" do
    it "maps self with value returned by given block" do
      expect(Mangrove::Result::Err.new(1).map_wt(Integer, Symbol) { Mangrove::Result::Ok.new(2) }).to eq Mangrove::Result::Ok.new(2)
      expect(Mangrove::Result::Err.new(:my_symbol).map_wt(Symbol, Symbol) { Mangrove::Result::Err.new(:my_new_symbol) }).to eq Mangrove::Result::Err.new(:my_new_symbol)
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
      expect(Mangrove::Result::Err[Symbol].new(:error).map_ok_wt(Symbol, &->(_) { :ok })).to eq Mangrove::Result::Err[Symbol].new(:error)
      expect(Mangrove::Result::Err[Symbol].new(:error).map_ok_wt(String, &->(_) { "ok" })).to eq Mangrove::Result::Err[Symbol].new(:error)
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
      expect(Mangrove::Result::Err[Symbol].new(:my_error).map_err_wt(Integer) { |_| 123 }).to eq Mangrove::Result::Err[Integer].new(123)
      expect(Mangrove::Result::Err[Symbol].new(:my_error).map_err_wt(String) { |_| "error" }).to eq Mangrove::Result::Err[String].new("error")
    end
  end

  describe "#tap_ok" do
    it "calls given block with inner value" do
      # 静的に到達しないことがわかってしまって型検査に通らないので、T.let で型を指定する
      expect(T.let(Mangrove::Result::Err.new(:my_symbol), Mangrove::Result[Integer, Symbol]).tap_ok { |i| i * 2 }).to eq Mangrove::Result::Err.new(:my_symbol)
      expect(T.let(Mangrove::Result::Err.new(1), Mangrove::Result[Symbol, Integer]).tap_ok(&:to_s)).to eq Mangrove::Result::Err.new(1)
    end
  end

  describe "#tap_err" do
    it "calls given block with inner value" do
      expect(Mangrove::Result::Err.new(1).tap_err(&:to_s)).to eq Mangrove::Result::Err.new(1)
      expect(Mangrove::Result::Err.new(:my_symbol).tap_err(&:to_s)).to eq Mangrove::Result::Err.new(:my_symbol)
    end
  end

  describe "#and" do
    it "returns self" do
      expect(Mangrove::Result::Err[Symbol].new(:error).and(Mangrove::Result::Ok[String].new("ok"))).to eq Mangrove::Result::Err[Symbol].new(:error)
    end
  end

  describe "#and_then" do
    it "maps inner value with value returned by given block" do
      expect(Mangrove::Result::Err[Symbol].new(:error).and_then(&->(_) { Mangrove::Result::Ok[String].new("err") })).to eq Mangrove::Result::Err[Symbol].new(:error)
      expect(Mangrove::Result::Err[Symbol].new(:error).and_then(&->(_) { Mangrove::Result::Ok[Symbol].new(:err) })).to eq Mangrove::Result::Err[Symbol].new(:error)
    end
  end

  describe "#and_then_wt" do
    it "maps inner value with value returned by given block" do
      expect(Mangrove::Result::Err[Symbol].new(:error).and_then_wt(String, &->(_) { Mangrove::Result.ok_wt("ok", Symbol) })).to eq Mangrove::Result::Err[Symbol].new(:error)
      expect(Mangrove::Result::Err[Symbol].new(:error).and_then_wt(Symbol, &->(_) { Mangrove::Result.err_wt(Symbol, :err) })).to eq Mangrove::Result::Err[Symbol].new(:error)
    end
  end

  describe "#and_err_if" do
    let(:err) { Mangrove::Result::Err[Symbol].new(:"my initial error") }

    context "when given block returns true" do
      it "returns self" do
        expect(err.and_err_if("my error") { |i| i == 0 }).to eq err
        expect(err.and_err_if(Exception.new) { |i| i == 0 }).to eq err
      end
    end

    context "when given block returns false" do
      it "returns self" do
        expect(err.and_err_if("my error") { |i| i != 0 }).to eq err
        expect(err.and_err_if(Exception.new) { |i| i != 0 }).to eq err
      end
    end
  end

  describe "#or" do
    it "returns other" do
      expect(Mangrove::Result::Err[Symbol].new(:error).or(Mangrove::Result::Ok[Integer].new(0))).to eq Mangrove::Result::Ok[Integer].new(0)
      expect(Mangrove::Result::Err[Symbol].new(:error).or(Mangrove::Result::Err[Symbol].new(:error))).to eq Mangrove::Result::Err[Symbol].new(:error)
    end
  end

  describe "#or_else" do
    it "returns other" do
      expect(Mangrove::Result::Err[Symbol].new(:error).or_else { |_| Mangrove::Result.ok_wt(2, String) }).to eq Mangrove::Result::Ok[Integer].new(2)
      expect(Mangrove::Result::Err[Symbol].new(:error).or_else { |_| Mangrove::Result.err_wt(Integer, :err) }).to eq Mangrove::Result::Err[Symbol].new(:err)
    end
  end

  describe "#or_then_wt" do
    it "returns other" do
      expect(Mangrove::Result::Err[Symbol].new(:error).or_else_wt(String) { |_| Mangrove::Result.ok_wt(2, String) }).to eq Mangrove::Result::Ok[Integer].new(2)
      expect(Mangrove::Result::Err[Symbol].new(:error).or_else_wt(String) { |_| Mangrove::Result.err_wt(Integer, "error") }).to eq Mangrove::Result::Err[String].new("error")
    end
  end

  describe "#or_ok_if" do
    let(:err) { Mangrove::Result::Err[Symbol].new(:my_initial_error) }

    context "when given block returns true" do
      it "returns a Result::Ok that contains the given argument" do
        expect(err.or_ok_if("my ok") { |i| i == :my_initial_error }).to eq Mangrove::Result::Ok[String].new("my ok")
        expect(err.or_ok_if(234) { |i| i == :my_initial_error }).to eq Mangrove::Result::Ok[Integer].new(234)
      end
    end

    context "when given block returns false" do
      it "returns self" do
        expect(err.or_ok_if("my error") { |i| i != :my_initial_error }).to eq err
        expect(err.or_ok_if(Exception.new) { |i| i != :my_initial_error }).to eq err
      end
    end
  end

  describe "#to_s" do
    it "includes inner value" do
      expect(Mangrove::Result::Err.new("my inner").to_s).to include ": inner=`my inner`"
    end
  end
end
