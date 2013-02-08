require 'pump/xml/node'

module Pump
  class Xml
    class Tag < Node
      INSTRUCT = "<?xml version=\\\"1.0\\\" encoding=\\\"UTF-8\\\"?>\n"

      def initialize(*args)
        super
        nodes.first.options = options if value_nodes?
      end

      def to_s
        if !value_nodes? || options[:never_blank]
          "#{condition_start}#{open_tag}#{value_and_close_tag}#{condition_end}"
        else
          "#{condition_start}#{open_tag}\#{v = #{nodes.first.plain};''}#{nil_attribute}\#{#{value_and_close_tag_with_blank_check}}#{condition_end}"
        end
      end

      private

      def value_nodes?
        Value === nodes.first
      end

      def open_tag
        "#{prefix}<#{name}#{attributes_string}"
      end

      def prefix
        if level == 0
          options[:instruct] ? INSTRUCT : (tabs)
        else
          "\n#{tabs}"
        end
      end

      def value_and_close_tag(path=nil)
        value = value_nodes? ? nodes.first.to_s(path) : (nodes.map(&:to_s).join << "\n")
        ">#{value}#{tabs unless value_nodes?}</#{name}>"
      end

      def value_and_close_tag_with_blank_check
        "#{blank_check} ? #{close_blank_tag} : \"#{value_and_close_tag('v')}\""
      end

      def attributes_string
        return "" if !attributes || attributes.size == 0
        attributes.inject('') do |str, (key, value)|
          str << " #{key}=\\\"#{value}\\\""
        end
      end

      def nil_attribute
        "\#{\" nil=\\\"true\\\"\" if v.nil?}" if options[:nil_check]
      end

      def blank_check
        if respond_to?(:blank?)
          "v.blank?"
        else
          "v.nil? || v == ''"
        end
      end

      def close_blank_tag
        "\"/>\""
      end

      def condition_start
        "\#{\"" if conditional?
      end

      def condition_end
        return unless conditional?

        if options[:if]
          "\" if object.#{options[:if]} }"
        elsif options[:unless]
          "\" unless object.#{options[:unless]} }"
        end
      end

      def conditional?
        !!(options[:if] || options[:unless])
      end
    end
  end
end