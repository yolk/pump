module Pump
  class Xml
    class Node
      attr_reader :name, :attributes, :nodes, :options
      attr_writer :level

      def initialize(name, attributes={}, nodes=[], options={})
        @name       = name
        @attributes = attributes || {}
        @options    = options || {}
        @nodes      = []
        Array(nodes).each{|node| add_node(node) }
      end

      def to_s
      end

      private

      def add_node(node)
        node.level = level + 1
        nodes << node
      end

      def level
        @level || options[:level] || 0
      end

      def indent
        (level)*(options[:indent] || 2)
      end
    end
  end
end