# typed: ignore
# frozen_string_literal: true

# rubocop:disable Lint/DuplicateBranch

require "mangrove/enum"
require "spec_helper"

class MyEnum
  extend Mangrove::Enum

  variants {
    variant VariantWithInteger, Integer
    variant VariantWithString, String
    variant VariantWithException, Exception
    variant VariantWithTuple, [Integer, String]
    variant VariantWithShape, { name: String, age: Integer }
  }
end

RSpec.describe Mangrove::Enum do
  it "can list subclesses" do
    expect(MyEnum.sealed_subclasses).to contain_exactly(
      MyEnum::VariantWithInteger,
      MyEnum::VariantWithString,
      MyEnum::VariantWithException,
      MyEnum::VariantWithTuple,
      MyEnum::VariantWithShape
    )
  end

  describe "#initialize" do
    it "checks inner values on runtime" do
      expect { MyEnum::VariantWithInteger.new("2").inner }.to raise_exception(TypeError, a_string_including("Expected type Integer, got type String with value \"2\""))
    end
  end

  describe "#inner" do
    it "returns the inner value" do
      expect(MyEnum::VariantWithInteger.new(2).inner).to eq 2
    end
  end

  describe "#as_super" do
    it "returns the enum as the super type" do
      expect(MyEnum::VariantWithInteger.new(2).as_super).to eq MyEnum::VariantWithInteger.new(2)
      expect { T.assert_type!(MyEnum::VariantWithInteger.new(2).as_super, MyEnum) }.not_to raise_exception
    end
  end

  describe "#==" do
    it "returns true when the inner values are equal" do
      expect(MyEnum::VariantWithShape.new({ name: "john", age: 23 })).to eq MyEnum::VariantWithShape.new({ name: "john", age: 23 })
    end
  end

  context "when used in case statement" do
    it "matches the self type" do
      expect {
        e = T.cast(MyEnum::VariantWithShape.new({ name: "john", age: 23 }), MyEnum)
        case e
        when MyEnum::VariantWithInteger
          raise
        when MyEnum::VariantWithString
          raise
        when MyEnum::VariantWithException
          raise
        when MyEnum::VariantWithTuple
          raise
        when MyEnum::VariantWithShape
          e
        else
          T.absurd(e)

          raise
        end
      }.not_to raise_exception
    end
  end
end

# rubocop:enable Lint/DuplicateBranch
