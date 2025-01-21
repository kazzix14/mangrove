# typed: ignore
# frozen_string_literal: true

require "rubygems/user_interaction"
require "spec_helper"
require "spoom"
require "tapioca/helpers/test/dsl_compiler"
require "tapioca/dsl/compilers/mangrove_result_ext"

RSpec.describe ::Tapioca::Compilers::MangroveResultExt do
  include ::Tapioca::Helpers::Test::DslCompiler

  describe ".gather_constants" do
    around(:example) { |example|
      load "tapioca/dsl/compilers/mangrove_result_ext.rb"
      use_dsl_compiler(Object.const_get("Tapioca::Compilers::MangroveResultExt"))
      example.run

      # Remove the class definition after the example to reload it
      Tapioca::Compilers.send(:remove_const, :MangroveResultExt)
    }

    it "gathers classes that includes Mangrove::Result::Ext" do
      add_ruby_file("content.rb", <<~RUBY)
        class Object
          include Mangrove::Result::Ext
        end

        class SomeOtherClass
        end
      RUBY

      allow(Tapioca::Compilers::MangroveResultExt).to receive(:all_classes).and_return([Object, SomeOtherClass])
      expect(gathered_constants).to contain_exactly("Object", "SomeOtherClass")
    end

    describe "#decorate" do
      it "generates RBI files for Result::Ext methods" do
        add_ruby_file("content.rb", <<~RUBY)
          class Object
            include Mangrove::Result::Ext
          end

          class SomeOtherClass
          end
        RUBY

        expected_object_rbi = <<~RBI
          # typed: strong

          class Object
            sig { returns(Mangrove::Result::Err[Object]) }
            def in_err; end

            sig { returns(Mangrove::Result::Ok[Object]) }
            def in_ok; end
          end
        RBI

        expected_some_other_class_rbi = <<~RBI
          # typed: strong

          class SomeOtherClass
            sig { returns(Mangrove::Result::Err[SomeOtherClass]) }
            def in_err; end

            sig { returns(Mangrove::Result::Ok[SomeOtherClass]) }
            def in_ok; end
          end
        RBI

        expect(rbi_for(:Object)).to eq(expected_object_rbi)
        expect(rbi_for(:SomeOtherClass)).to eq(expected_some_other_class_rbi)
      end
    end
  end
end
