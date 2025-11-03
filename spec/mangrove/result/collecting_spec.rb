# typed: false
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
    it "returns the inner value if it does not encouter an error" do
      final = Mangrove::Result.collecting(Integer, String) { |ctx|
        seems_ok_a = T.let(Mangrove::Result.ok(100), Mangrove::Result[Integer, String])
        seems_ok_b = T.let(Mangrove::Result.ok(3), Mangrove::Result[Integer, String])

        a = seems_ok_a.unwrap_in(ctx)
        b = seems_ok_b.unwrap_in(ctx)
        Mangrove::Result.ok(a * b)
      }

      expect(final).to eq(Mangrove::Result::Ok.new(300))
    end
  end

  describe "Result::Err#unwrap_in" do
    it "returns error inner if it encounters an error" do
      final = Mangrove::Result.collecting(Integer, String) { |ctx|
        seems_ok_a = T.let(Mangrove::Result.ok_wt(100, String), Mangrove::Result[Integer, String])
        seems_err_b = T.let(Mangrove::Result.err_wt(String, "error"), Mangrove::Result[Integer, String])

        a = seems_ok_a.unwrap_in(ctx)
        b = seems_err_b.unwrap_in(ctx)

        # ↓ここには到達しない
        Mangrove::Result.ok(a * b)
      }

      expect(final).to eq(Mangrove::Result::Err.new("error"))
    end
  end
end
