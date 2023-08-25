# typed: strict
# frozen_string_literal: true

require "spec_helper"
require "mangrove/option"
require "mangrove/control_flow"

class MyClass
  extend T::Sig

  include Mangrove::ControlFlow::Handler

  sig { params(nums: T::Array[Mangrove::Option[Integer]]).returns(Mangrove::Result[Integer, String]) }
  def self.my_method(nums)
    Mangrove::Result::Ok.new(nums
      .map { |num| mul_by_2(num) }
      .map(&:unwrap!)
      .sum)
  end

  sig { params(num: Mangrove::Option[Integer]).returns(Mangrove::Result[Integer, String]) }
  def self.mul_by_2(num)
    Mangrove::Result::Ok.new(2 * num.unwrap!)
  end
end

RSpec.describe Mangrove::ControlFlow do
  context "rescuing from Option::None#unwrap!" do
    it "returns Result" do
      expect(MyClass.mul_by_2(Mangrove::Option::Some.new(2))).to eq Mangrove::Result::Ok.new(4)
    end

    it "returns Result" do
      expect(MyClass.mul_by_2(Mangrove::Option::None.new)).to be_a Mangrove::Result::Err
    end

    it "returns Result" do
      expect(MyClass.my_method([
                                 Mangrove::Option::Some.new(2),
                                 Mangrove::Option::Some.new(5),
                                 Mangrove::Option::Some.new(3)
                               ])).to eq Mangrove::Result::Ok.new(2 * 2 + 5 * 2 + 3 * 2)
    end

    it "returns Result" do
      expect(MyClass.my_method([
                                 Mangrove::Option::Some.new(2),
                                 Mangrove::Option::None.new,
                                 Mangrove::Option::Some.new(5),
                                 Mangrove::Option::Some.new(3)
                               ])).to be_a Mangrove::Result::Err
    end
  end
end
