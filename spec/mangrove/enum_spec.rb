# typed: ignore
# frozen_string_literal: true

# rubocop:disable Lint/DuplicateBranch

require "mangrove/enum"
require "spec_helper"

class MyEnum
  extend Mangrove::Enum

  class ChildEnum
    extend Mangrove::Enum

    variants {
      variant VariantWithShape, { name: String, age: Integer }
    }
  end

  variants {
    variant VariantWithInteger, Integer
    variant VariantWithString, String
    variant VariantWithException, Exception
    variant VariantWithTuple, [Integer, String]
    variant VariantWithShape, { name: String, age: Integer }
    variant VariantWithChild, ChildEnum
  }
end

RSpec.describe Mangrove::Enum do
  it "can list subclasses" do
    expect(MyEnum.sealed_subclasses).to contain_exactly(
      MyEnum::VariantWithInteger,
      MyEnum::VariantWithString,
      MyEnum::VariantWithException,
      MyEnum::VariantWithTuple,
      MyEnum::VariantWithShape,
      MyEnum::VariantWithChild
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

  describe "serialize" do
    it "serializes the enum to a hash" do
      expect(
        MyEnum::VariantWithChild.new(
          MyEnum::ChildEnum::VariantWithShape.new({ name: "john", age: 23 })
        ).respond_to?(:serialize)
      ).to be_truthy
      expect(
        MyEnum::VariantWithInteger.new(2).serialize
      ).to eq({ type: "MyEnum::VariantWithInteger", value: 2 })

      expect(
        MyEnum::VariantWithChild.new(
          MyEnum::ChildEnum::VariantWithShape.new({ name: "john", age: 23 })
        ).serialize
      ).to eq(
        {
          type: "MyEnum::VariantWithChild",
          value: {
            type: "MyEnum::ChildEnum::VariantWithShape",
            value: {
              name: "john",
              age: 23
            }
          }
        }
      )
    end
  end

  describe "#deserialize" do
    it "deserializes the enum from a hash" do
      expect(MyEnum.deserialize({ type: "MyEnum::VariantWithInteger", value: 2 })).to eq MyEnum::VariantWithInteger.new(2)
      expect(
        MyEnum.deserialize(
          {
            type: "MyEnum::VariantWithChild",
            value: {
              type: "MyEnum::ChildEnum::VariantWithShape",
              value: {
                name: "john",
                age: 23
              }
            }
          }
        )
      ).to eq MyEnum::VariantWithChild.new(
        MyEnum::ChildEnum::VariantWithShape.new({ name: "john", age: 23 })
      )
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
        when MyEnum::VariantWithChild
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
