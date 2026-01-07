# typed: false
# frozen_string_literal: true

require "spec_helper"
require "mangrove/result"

RSpec.describe "Mangrove::Result::Collector" do
  describe "#yield" do
    it "works" do
      Mangrove::Result::Collector[T.nilable(Integer), T.nilable(String)].new.collecting do |ctx|
        ctx.try!(Mangrove::Result::Ok.new(10))
        ctx.try!(Mangrove::Result::Ok.new("yo"))
        ctx.try!(Mangrove::Result::Err.new("yo"))
      end
    end
  end
end
