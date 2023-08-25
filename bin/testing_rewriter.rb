# typed: true

require "parser"
require "parser/current"
require "unparser"
require "method_source"
require "sorbet-runtime"


class MyClass
  extend T::Sig

  sig { void }
  def my_method
  end

  def my_method_2
    puts 'shhhhhh'
  end

  def my_method_3
    puts 'shhhhhh'
  rescue AAA
  rescue BBB
  rescue MyError => e
    e.inner_value
  end

  def my_method_4
    puts "body puts"
  ensure
    puts "ensure puts"
  end

  def my_method_5
    puts "body puts"
  rescue
    puts "rescue puts"
  ensure
    puts "ensure puts"
  end
end


@control_flow = StandardError

def rescue_body_node
  control_flow = StandardError

  ::Parser::AST::Node.new(:resbody, [
    ::Parser::AST::Node.new(:array, [
      ::Parser::AST::Node.new(:const, [nil, control_flow.to_s])
    ]),
    ::Parser::AST::Node.new(:lvasgn, [:exception]),
    ::Parser::AST::Node.new(:send, [
      ::Parser::AST::Node.new(:const, [
        ::Parser::AST::Node.new(:const, [
          nil,
          :Result,
        ]),
        :Err,
      ]),
      :new,
      ::Parser::AST::Node.new(:lvar, [:exception])
    ]),
  ])
end

def rescue_node(body)
  ::Parser::AST::Node.new(:rescue, [
    body,
    nil,
  ])
end

def add_rescue_node(parent)
  children = parent.children.dup
  # nilの場合はblockをこちらで包む必要がある
  # nilではない場合はすでに包まれているのでこちらで包む必要はない
  method_body_index = children.length - 1
  method_body = children[method_body_index]

  children[method_body_index] = rescue_node(method_body)
  updated = parent.updated(nil, children)
  updated
end

def use_rescue_node(parent)
  children = parent.children.dup
  rescue_index = children.find_index { _1.respond_to?(:type) && _1.type == :rescue }

  rescue_node_on_ast = children[rescue_index]
  updated_rescue_node_on_ast = insert_rescue_body_node(rescue_node_on_ast)
  children[rescue_index] = updated_rescue_node_on_ast

  updated = parent.updated(nil, children)
  updated
end

def insert_rescue_body_node(rescue_node)
  rescue_node_children = rescue_node.children.dup
  rescue_body_node_index = rescue_node_children.find_index { _1.respond_to?(:type) && _1.type == :resbody }
  rescue_node_children.insert(rescue_body_node_index, rescue_body_node)
  updated = rescue_node.updated(nil, rescue_node_children)
  updated
end

def use_ensure_node(ensure_node)
  # ensureのchildrenの最後から2番目（最後のrescue）に追加する

  ensure_node_children = ensure_node.children.dup

  rescue_index = ensure_node_children.find_index { _1.respond_to?(:type) && _1.type == :rescue }

  if rescue_index.nil?
    parent = add_rescue_node(ensure_node)
  end

  updated_ensure_node = use_rescue_node(ensure_node)

  updated_ensure_node
end

def with_rescue(parent)
  children = parent.children.dup
  ensure_index = children.find_index { _1.respond_to?(:type) && _1.type == :ensure }

  unless ensure_index.nil?
    updated_ensure_node = use_ensure_node(children[ensure_index])
    children[ensure_index] = updated_ensure_node
    parent.updated(nil, children)
  else
    rescue_index = children.find_index { _1.respond_to?(:type) && _1.type == :rescue }

    if rescue_index.nil?
      parent = add_rescue_node(parent)
    end

    use_rescue_node(parent)
  end
end

class MyRewriter < Parser::TreeRewriter
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
end

source = MyClass.instance_method(:my_method_5).source
parsed = Parser::CurrentRuby.parse(source)
puts "parsed -------------------------------------"
pp parsed
source_buffer = Parser::Source::Buffer.new("(example)", source:)
rewriter = MyRewriter.new
puts "rewritten -------------------------------------"
puts rewriter.rewrite(source_buffer, parsed)

exit
