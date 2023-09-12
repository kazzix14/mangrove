# typed: true
# frozen_string_literal: true

require "parser"
require "parser/current"
require "unparser"
require "method_source"
require "sorbet-runtime"

module Mangrove
  module ControlFlow
    class << self
      extend T::Sig

      sig { params(method_to_be_rewritten: T.any(Method, UnboundMethod)).returns(String) }
      def impl!(method_to_be_rewritten)
        filename, line_number = method_to_be_rewritten.source_location

        source = method_to_be_rewritten.source
        ast = Parser::CurrentRuby.parse(source)
        source_buffer = Parser::Source::Buffer.new("#{filename}:#{line_number}", source:)
        rewriter = Rewriter.new
        rewriter.rewrite(source_buffer, ast)
      end
    end

    class Rewriter < Parser::TreeRewriter
      CONTROL_SIGNAL = Mangrove::ControlFlow::ControlSignal

      def on_def(node)
        indent = node.location.expression.begin.column
        code = Unparser.unparse(with_rescue(node))
        indented_code = code.lines.map.with_index { |line, index| index.zero? ? line : (" " * indent) + line }
        replace(node.location.expression, indented_code)
      end

      def on_defs(node)
        indent = node.location.expression.begin.column
        code = Unparser.unparse(with_rescue(node))
        indented_code = code.lines.map.with_index { |line, index| index.zero? ? line : (" " * indent) + line }
        replace(node.location.expression, indented_code)
      end

      def on_block(node)
        indent = node.location.expression.begin.column
        code = Unparser.unparse(with_rescue(node))
        indented_code = code.lines.map.with_index { |line, index| index.zero? ? line : (" " * indent) + line }
        replace(node.location.expression, indented_code)
      end

      private

      def rescue_node(body)
        ::Parser::AST::Node.new(:rescue, [
          body,
          nil
        ])
      end

      def add_rescue_node(parent)
        children = parent.children.dup
        # nilの場合はblockをこちらで包む必要がある
        # nilではない場合はすでに包まれているのでこちらで包む必要はない
        method_body_index = children.length - 1
        method_body = children[method_body_index]

        children[method_body_index] = rescue_node(method_body)
        parent.updated(nil, children)
      end

      def use_rescue_node(parent)
        children = parent.children.dup

        rescue_index = children.find_index { _1.respond_to?(:type) && _1.type == :rescue }

        rescue_node_on_ast = children[rescue_index]
        updated_rescue_node_on_ast = insert_rescue_body_node(rescue_node_on_ast)
        children[rescue_index] = updated_rescue_node_on_ast

        parent.updated(nil, children)
      end

      def insert_rescue_body_node(rescue_node)
        rescue_node_children = rescue_node.children.dup
        rescue_body_node_index = rescue_node_children.find_index { _1.respond_to?(:type) && _1.type == :resbody }

        # when rescue is newly inserted
        if rescue_body_node_index.nil?
          rescue_body_node_index = rescue_node_children.length - 1
        end

        rescue_node_children.insert(rescue_body_node_index, rescue_body_node)
        rescue_node.updated(nil, rescue_node_children)
      end

      def use_ensure_node(ensure_node)
        # ensureのchildrenの最後から2番目（最後のrescue）に追加する

        ensure_node_children = ensure_node.children.dup

        rescue_index = ensure_node_children.find_index { _1.respond_to?(:type) && _1.type == :rescue }

        if rescue_index.nil?
          ensure_node = add_rescue_node(ensure_node)
        end

        use_rescue_node(ensure_node)
      end

      def with_rescue(parent)
        children = parent.children.dup
        ensure_index = children.find_index { _1.respond_to?(:type) && _1.type == :ensure }

        if ensure_index.nil?
          rescue_index = children.find_index { _1.respond_to?(:type) && _1.type == :rescue }

          if rescue_index.nil?
            parent = add_rescue_node(parent)
          end

          use_rescue_node(parent)
        else
          updated_ensure_node = use_ensure_node(children[ensure_index])
          children[ensure_index] = updated_ensure_node
          parent.updated(nil, children)
        end
      end

      def rescue_body_node
        control_flow = Mangrove::ControlFlow::ControlSignal

        ::Parser::AST::Node.new(:resbody, [
          ::Parser::AST::Node.new(:array, [
            ::Parser::AST::Node.new(:const, [nil, control_flow.to_s])
          ]),
          ::Parser::AST::Node.new(:lvasgn, [:exception]),
          ::Parser::AST::Node.new(:send, [
            ::Parser::AST::Node.new(:const, [
              ::Parser::AST::Node.new(:const, [
                ::Parser::AST::Node.new(:const, %i[
                  cbase
                  Mangrove
                ]),
                :Result
              ]),
              :Err
            ]),
            :new,
            ::Parser::AST::Node.new(:send, [
              ::Parser::AST::Node.new(:lvar, [:exception]),
              :inner_value
            ])
          ])
        ])
      end
    end
  end
end
