# typed: ignore
# frozen_string_literal: true

require "rubygems/user_interaction"
require "spec_helper"
require "spoom"
require "tapioca/helpers/test/dsl_compiler"
require "tapioca/dsl/compilers/mangrove_try_from_ext"

RSpec.describe ::Tapioca::Compilers::TryFromExt do
  include ::Tapioca::Helpers::Test::DslCompiler

  describe ".gather_constants" do
    around(:example) { |example|
      load "tapioca/dsl/compilers/mangrove_try_from_ext.rb"
      use_dsl_compiler(Object.const_get("Tapioca::Compilers::TryFromExt"))
      example.run

      # Remove the class definition after the example to reload it
      Tapioca::Compilers.send(:remove_const, :TryFromExt)
    }

    it "gathers no constants if there are no classes that extend Mangrove::TryFromExt" do
      allow(Tapioca::Compilers::TryFromExt).to receive(:all_classes).and_return([String])
      expect(gathered_constants).to be_empty
    end

    it "gathers only classes that extend Mangrove::TryFromExt" do
      add_ruby_file("content.rb", <<~RUBY)
        class SourceClass
          extend T::Sig

          sig { returns(String) }
          def value = "test"
        end

        class DestinationClass
          extend T::Sig
          extend Mangrove::TryFromExt

          try_convert_from(from: SourceClass, to: DestinationClass, err: StandardError, &lambda { |source|
            Mangrove::Result::Ok.new(source.value)
          })
        end

        class OtherClass
        end
      RUBY

      allow(Tapioca::Compilers::TryFromExt).to receive(:all_classes).and_return([SourceClass, DestinationClass, OtherClass])
      expect(gathered_constants).to contain_exactly("DestinationClass")
    end

    describe "#decorate" do
      it "generates RBI files for try_from conversion methods" do
        add_ruby_file("content.rb", <<~RUBY)
          class SourceClass
            extend T::Sig

            sig { returns(String) }
            def value = "test"
          end

          class DestinationClass
            extend T::Sig
            extend Mangrove::TryFromExt

            try_convert_from(from: SourceClass, to: DestinationClass, err: StandardError, &lambda { |source|
              Mangrove::Result::Ok.new(source.value)
            })
          end
        RUBY

        expected = <<~RBI
          # typed: strong

          class SourceClass
            sig { returns(Mangrove::Result[DestinationClass, StandardError]) }
            def try_into_destination_class; end
          end
        RBI

        expect(rbi_for(:DestinationClass)).to eq(expected)
      end

      context "when there are multiple conversion sources" do
        it "generates RBI files for all conversion methods" do
          add_ruby_file("content.rb", <<~RUBY)
            class FirstSource
              extend T::Sig
              sig { returns(String) }
              def value = "test"
            end

            class SecondSource
              extend T::Sig
              sig { returns(Integer) }
              def number = 42
            end

            class DestinationClass
              extend T::Sig
              extend Mangrove::TryFromExt

              try_convert_from(from: FirstSource, to: DestinationClass, err: String, &lambda { |source|
                Mangrove::Result::Ok.new(source.value)
              })

              try_convert_from(from: SecondSource, to: DestinationClass, err: Integer, &lambda { |source|
                Mangrove::Result::Ok.new(source.number.to_s)
              })
            end
          RUBY

          expected = <<~RBI
            # typed: strong

            class FirstSource
              sig { returns(Mangrove::Result[DestinationClass, String]) }
              def try_into_destination_class; end
            end

            class SecondSource
              sig { returns(Mangrove::Result[DestinationClass, Integer]) }
              def try_into_destination_class; end
            end

            class SourceClass
              sig { returns(Mangrove::Result[DestinationClass, StandardError]) }
              def try_into_destination_class; end
            end
          RBI

          expect(rbi_for(:DestinationClass)).to eq(expected)
        end
      end

      context "when there are no conversions defined" do
        it "generates no RBI files" do
          add_ruby_file("content.rb", <<~RUBY)
            class EmptyDestination
              extend T::Sig
              extend Mangrove::TryFromExt
            end
          RUBY

          expect(rbi_for(:EmptyDestination)).to eq "# typed: strong\n"
        end
      end
    end
  end
end
