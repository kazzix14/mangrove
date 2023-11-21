# typed: ignore
# frozen_string_literal: true

require "rubygems/user_interaction"
require "spec_helper"
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
        class MyEnumForDslCompiler
          extend Mangrove::Enum

          variants do
            variant MyEnumVariant, Integer
          end
        end

        class OtherClass
        end
      RUBY

      allow(Tapioca::Compilers::MangroveEnum).to receive(:all_classes).and_return([MyEnumForDslCompiler, OtherClass])
      expect(gathered_constants).to contain_exactly("MyEnumForDslCompiler")
    end

    describe "#decorate" do
      it "generates RBI files for enums" do
        allow(Tapioca::Compilers::MangroveEnum).to receive(:all_classes).and_return([MyEnumForDslCompiler, OtherClass])

        expected = <<~RBI
          # typed: strong

          class MyEnumForDslCompiler
            abstract!
            sealed!

            sig { returns(MyEnumForDslCompiler) }
            def as_super; end

            sig { returns(T.any(Integer)) }
            def inner; end

            class MyEnumVariant < ::MyEnumForDslCompiler
              sig { params(inner: Integer).void }
              def initialize(inner); end

              sig { returns(MyEnumForDslCompiler) }
              def as_super; end

              sig { returns(Integer) }
              def inner; end
            end

            abstract!
            sealed!
          end
        RBI

        expect(rbi_for(:MyEnumForDslCompiler)).to eq(expected)
      end
    end
  end
end
