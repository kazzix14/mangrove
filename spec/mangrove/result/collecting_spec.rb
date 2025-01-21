# typed: strict
# frozen_string_literal: true

require "spec_helper"
require "mangrove/result"

RSpec.describe "Mangrove::Result.collecting" do
  describe "CollectingContext#try!" do
    context "when all results are Ok" do
      it "returns the final Ok as declared in the block" do
        final = Mangrove::Result.collecting(Integer, String) { |ctx|
          a = ctx.try!(Mangrove::Result::Ok.new(10))
          b = ctx.try!(Mangrove::Result::Ok.new(20))
          Mangrove::Result::Ok.new(a + b)
        }

        expect(final).to eq(Mangrove::Result::Ok.new(30))
      end
    end

    context "when an Err is encountered" do
      it "short-circuits and returns the Err" do
        final = Mangrove::Result.collecting(Integer, String) { |ctx|
          a = ctx.try!(Mangrove::Result::Ok.new(1))
          # ここで Err が帰ってきたら short-circuit する
          b = ctx.try!(Mangrove::Result::Err.new("boom"))

          # ↓ここには到達しない
          Mangrove::Result::Ok.new(a + b)
        }

        expect(final).to eq(Mangrove::Result::Err.new("boom"))
      end
    end

    context "with multiple attempts" do
      it "short-circuits on the first Err and ignores subsequent code" do
        final = Mangrove::Result.collecting(Integer, String) { |ctx|
          ctx.try!(Mangrove::Result::Ok.new(100))
          ctx.try!(Mangrove::Result::Err.new("first error"))

          # ここは呼ばれないはず
          ctx.try!(Mangrove::Result::Err.new("second error"))
          Mangrove::Result::Ok.new(9999)
        }

        expect(final).to eq(Mangrove::Result::Err.new("first error"))
      end
    end
  end

  describe "Result::Ok#unwrap_in" do
    it "returns the inner value" do
      ok = Mangrove::Result::Ok.new(100)
      ctx = Mangrove::Result::CollectingContext.new

      expect(ok.unwrap_in(ctx)).to eq(100)
    end
  end

  describe "Result::Err#unwrap_in" do
    it "raises an error" do
      err = Mangrove::Result::Err.new("boom")
      ctx = Mangrove::Result::CollectingContext.new

      expect { err.unwrap_in(ctx) }.to throw_symbol(:__mangrove_result_collecting_context_return, err)
    end
  end
end
