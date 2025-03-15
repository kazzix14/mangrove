# typed: ignore
# frozen_string_literal: true

# rubocop:disable Lint/ConstantDefinitionInBlock
require "spec_helper"

RSpec.describe Mangrove::TryFromExt do
  describe ".try_convert_from" do
    before do
      # テスト用のクラスを定義
      class TestSource
        extend T::Sig

        sig { returns(String) }
        attr_reader :value

        sig { params(value: String).void }
        def initialize(value)
          @value = value
        end
      end

      class TestDestination
        extend T::Sig
        extend Mangrove::TryFromExt

        sig { returns(Integer) }
        attr_reader :number

        sig { params(number: Integer).void }
        def initialize(number)
          @number = number
        end

        # TestSourceからTestDestinationへの変換を定義
        try_convert_from(TestSource, StandardError) do |source|
          Mangrove::Result::Ok.new(TestDestination.new(Integer(source.value)))
        rescue ArgumentError => e
          Mangrove::Result::Err.new(e)
        end
      end
    end

    after do
      Object.send(:remove_const, :TestSource)
      Object.send(:remove_const, :TestDestination)
    end

    context "when conversion is successful" do
      it "converts from source to destination type" do
        source = TestSource.new("42")
        result = source.try_into_test_destination

        expect(result).to be_a(Mangrove::Result::Ok)
        expect(result.ok_inner).to be_a(TestDestination)
        expect(result.ok_inner.number).to eq(42)
      end
    end

    context "when conversion fails" do
      it "returns Err with the error" do
        source = TestSource.new("not a number")
        result = source.try_into_test_destination

        expect(result).to be_a(Mangrove::Result::Err)
        expect(result.err_inner).to be_a(ArgumentError)
      end
    end

    context "with multiple conversions" do
      before do
        class AnotherDestination
          extend T::Sig
          extend Mangrove::TryFromExt

          sig { returns(String) }
          attr_reader :text

          sig { params(text: String).void }
          def initialize(text)
            @text = text
          end

          try_convert_from(TestSource, StandardError) do |source|
            Mangrove::Result::Ok.new(new(source.value.upcase))
          end
        end
      end

      after do
        Object.send(:remove_const, :AnotherDestination)
      end

      it "allows multiple conversion definitions for the same source type" do
        source = TestSource.new("hello")

        # 数値への変換は失敗
        number_result = source.try_into_test_destination
        expect(number_result).to be_a(Mangrove::Result::Err)

        # 文字列への変換は成功
        string_result = source.try_into_another_destination
        expect(string_result).to be_a(Mangrove::Result::Ok)
        expect(string_result.ok_inner.text).to eq("HELLO")
      end
    end

    context "with inheritance" do
      before do
        class ChildSource < TestSource; end
      end

      after do
        Object.send(:remove_const, :ChildSource)
      end

      it "works with inherited classes" do
        source = ChildSource.new("42")
        result = source.try_into_test_destination

        expect(result).to be_a(Mangrove::Result::Ok)
        expect(result.ok_inner.number).to eq(42)
      end
    end
  end
end

# rubocop:enable Lint/ConstantDefinitionInBlock
