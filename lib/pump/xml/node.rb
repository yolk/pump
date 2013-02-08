module Pump
  class Xml
    class Node
      attr_reader :name, :attributes, :nodes, :options

      def initialize(name, attributes={}, nodes=[], options={})
        @name       = name
        @attributes = attributes || {}
        @options    = (options || {}).dup
        @nodes      = []
        Array(nodes).each{|node| add_node(node) }
      end

      def to_s
      end

      def level=(new_level)
        @level = new_level
        nodes.each{|node| node.level = @level + 1}
      end

      private

      def add_node(node)
        node.level = level + 1
        node.options[:extra_indent] = options[:extra_indent]
        nodes << node
      end

      def level
        @level || options[:level] || 0
      end

      def tabs
        " " * ((level + extra_indent) * 2)
      end

      def extra_indent
        options[:extra_indent] || 0
      end
    end
  end
end