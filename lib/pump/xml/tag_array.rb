require 'pump/xml/node'
require 'active_support/core_ext/string/inflections'

module Pump
  class Xml
    class TagArray < Node
      def initialize(name, attributes={}, nodes=[], options={})
        tag = Tag.new(name, attributes, nodes, {:level => 1, :extra_indent => options[:extra_indent]})
        super(name.pluralize, {}, [tag], options)
      end

      def to_s
        "#{prefix}<#{name} type=\\\"array\\\"#{loop_and_close_tag}"
      end

      private

      def prefix
        options[:instruct] ? "#{Tag::INSTRUCT}" : tabs
      end

      def loop_and_close_tag
        "\#{ objects.empty? ? \" />\" : \">#{tag_loop}#{tabs}</#{name}>\" }"
      end

      def tag_loop
        "\#{objects.map{|object| \"#{nodes.first}\" }.join('')}\n"
      end
    end
  end
end