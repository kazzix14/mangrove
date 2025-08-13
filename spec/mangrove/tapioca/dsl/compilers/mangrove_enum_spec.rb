# typed: ignore
# frozen_string_literal: true

require "rubygems/user_interaction"
require "spec_helper"
require "spoom"
require "tapioca/helpers/test/dsl_compiler"
require "tapioca/dsl/compilers/mangrove_enum"

RSpec.describe ::Tapioca::Compilers::MangroveEnum do
  include ::Tapioca::Helpers::Test::DslCompiler

  describe ".gather_constants" do
    around(:example) { |example|
      load "tapioca/dsl/compilers/mangrove_enum.rb"
      use_dsl_compiler(Object.const_get("Tapioca::Compilers::MangroveEnum"))
      example.run

      # Remove the class definition after the example to reload it
      Tapioca::Compilers.send(:remove_const, :MangroveEnum)
    }

    it "gathers no constants if there are no classes that extends Mangrove::Enum" do
      allow(Tapioca::Compilers::MangroveEnum).to receive(:all_classes).and_return([String])
      expect(gathered_constants).to be_empty
    end

    it "gathers only classes that extends Mangrove::Enum" do
      add_ruby_file("content.rb", <<~RUBY)
        class ClassWithInspection
         def self.inspect = "inspection!"
        end

        class MyEnumForDslCompiler
          extend Mangrove::Enum

          variants do
            variant MyEnumVariant2, String
            variant MyEnumVariant1, { a: ClassWithInspection, b: Integer }
            variant MyEnumVariant0, Integer
            variant MyEnumVariant3, [Integer, ClassWithInspection]
          end
        end

        class OtherClass
        end
      RUBY

      allow(Tapioca::Compilers::MangroveEnum).to receive(:all_classes).and_return([MyEnumForDslCompiler, OtherClass])
      expect(gathered_constants).to contain_exactly("MyEnumForDslCompiler")
    end

    describe "#decorate" do
      it "generates RBI files for enums. RBI is always be sorted." do
        allow(Tapioca::Compilers::MangroveEnum).to receive(:all_classes).and_return([MyEnumForDslCompiler, OtherClass])

        expected = <<~RBI
          # typed: strong

          class MyEnumForDslCompiler
            abstract!
            sealed!

            sig { returns(MyEnumForDslCompiler) }
            def as_super; end

            sig { params(hash: T::Hash[T.any(Symbol, String), T.untyped]).returns(MyEnumForDslCompiler) }
            def deserialize(hash); end

            sig { returns(T.any(Integer, { a: ClassWithInspection, b: Integer }, String, [Integer, ClassWithInspection])) }
            def inner; end

            sig { params(inner_serialization_methods: T.nilable(T::Array[Symbol])).returns(T::Hash[Symbol, T.untyped]) }
            def serialize(inner_serialization_methods); end

            class MyEnumVariant0 < ::MyEnumForDslCompiler
              sig { params(inner: Integer).void }
              def initialize(inner); end

              sig { returns(MyEnumForDslCompiler) }
              def as_super; end

              sig { returns(Integer) }
              def inner; end

              sig { params(inner_serialization_methods: T.nilable(T::Array[Symbol])).returns(T::Hash[Symbol, T.untyped]) }
              def serialize(inner_serialization_methods); end
            end

            class MyEnumVariant1 < ::MyEnumForDslCompiler
              sig { params(inner: { a: ClassWithInspection, b: Integer }).void }
              def initialize(inner); end

              sig { returns(MyEnumForDslCompiler) }
              def as_super; end

              sig { returns({ a: ClassWithInspection, b: Integer }) }
              def inner; end

              sig { params(inner_serialization_methods: T.nilable(T::Array[Symbol])).returns(T::Hash[Symbol, T.untyped]) }
              def serialize(inner_serialization_methods); end
            end

            class MyEnumVariant2 < ::MyEnumForDslCompiler
              sig { params(inner: String).void }
              def initialize(inner); end

              sig { returns(MyEnumForDslCompiler) }
              def as_super; end

              sig { returns(String) }
              def inner; end

              sig { params(inner_serialization_methods: T.nilable(T::Array[Symbol])).returns(T::Hash[Symbol, T.untyped]) }
              def serialize(inner_serialization_methods); end
            end

            class MyEnumVariant3 < ::MyEnumForDslCompiler
              sig { params(inner: [Integer, ClassWithInspection]).void }
              def initialize(inner); end

              sig { returns(MyEnumForDslCompiler) }
              def as_super; end

              sig { returns([Integer, ClassWithInspection]) }
              def inner; end

              sig { params(inner_serialization_methods: T.nilable(T::Array[Symbol])).returns(T::Hash[Symbol, T.untyped]) }
              def serialize(inner_serialization_methods); end
            end

            abstract!
            sealed!
          end
        RBI

        expect(rbi_for(:MyEnumForDslCompiler)).to eq(expected)
      end

      context "when there is only one variant" do
        it "generates RBI files for enums." do
          add_ruby_file("content.rb", <<~RUBY)
            class MyEnumWithOneVariant
              extend Mangrove::Enum

              variants do
                variant MyEnumVariant1, String
              end
            end
          RUBY

          expected = <<~RBI
            # typed: strong

            class MyEnumWithOneVariant
              abstract!
              sealed!

              sig { returns(MyEnumWithOneVariant) }
              def as_super; end

              sig { params(hash: T::Hash[T.any(Symbol, String), T.untyped]).returns(MyEnumWithOneVariant) }
              def deserialize(hash); end

              sig { returns(String) }
              def inner; end

              sig { params(inner_serialization_methods: T.nilable(T::Array[Symbol])).returns(T::Hash[Symbol, T.untyped]) }
              def serialize(inner_serialization_methods); end

              class MyEnumVariant1 < ::MyEnumWithOneVariant
                sig { params(inner: String).void }
                def initialize(inner); end

                sig { returns(MyEnumWithOneVariant) }
                def as_super; end

                sig { returns(String) }
                def inner; end

                sig { params(inner_serialization_methods: T.nilable(T::Array[Symbol])).returns(T::Hash[Symbol, T.untyped]) }
                def serialize(inner_serialization_methods); end
              end

              abstract!
              sealed!
            end
          RBI

          expect(rbi_for(:MyEnumWithOneVariant)).to eq(expected)
        end
      end
    end
  end
end
