require 'pump/xml/node'
require 'active_support/core_ext/string/inflections'

module Pump
  class Xml
    class TagArray < Node
      def initialize(name, attributes={}, nodes=[], options={})
        tag = Tag.new(name, attributes, nodes, {:level => 1, :extra_indent => options[:extra_indent]})
        array_root = options[:array_root] || name.to_s.pluralize
        super(array_root, {}, [tag], options)
      end

      def to_s
        if options.has_key?(:static_value)
          "#{prefix}<#{name} type=\\\"array\\\"#{static_value_and_close_tag}"
        else
          "#{prefix}<#{name} type=\\\"array\\\"#{loop_and_close_tag}"
        end
      end

      private

      def prefix
        options[:instruct] ? "#{Tag::INSTRUCT}" : tabs
      end

      def loop_and_close_tag
        "\#{ #{objects_path}.empty? ? \"/>\n\" : \">\n#{tag_loop}#{tabs}</#{name}>\n\" }"
      end

      def static_value_and_close_tag
        return "/>\n" if options[:static_value].nil?
        ">#{options[:static_value]}</#{name}>\n"
      end

      def objects_path
        options[:array_method] ? "object.#{options[:array_method]}" : "objects"
      end

      def tag_loop
        "\#{#{objects_path}.map{|object| \"#{nodes.first}\" }.join('')}"
      end
    end
  end
end