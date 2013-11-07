require 'pump/xml/node'

module Pump
  class Xml
    class Tag < Node
      INSTRUCT = "<?xml version=\\\"1.0\\\" encoding=\\\"UTF-8\\\"?>\n"

      def initialize(*args)
        super
        if value_nodes?
          nodes.first.options = options
        end
      end

      def to_s
        if options.has_key?(:static_value)
          "#{condition_start}#{open_tag}#{static_value_and_close_tag}#{condition_end}"
        elsif !value_nodes? || options[:never_nil]
          "#{condition_start}#{open_tag}#{value_and_close_tag}#{condition_end}"
        else
          "#{condition_start}#{open_tag}\#{v = #{nodes.first.plain};''}\#{#{value_and_close_tag_with_nil_check}}#{condition_end}"
        end
      end

      private

      def value_nodes?
        Value === nodes.first
      end

      def open_tag
        "#{prefix}<#{format_name(name)}#{attributes_string}"
      end

      def prefix
        if level == 0
          options[:instruct] ? INSTRUCT : (tabs)
        else
          "#{tabs}"
        end
      end

      def value_and_close_tag(path=nil)
        value = value_nodes? ? nodes.first.to_s(path) : ("\n" << nodes.map(&:to_s).join)
        ">#{value}#{tabs unless value_nodes?}</#{format_name(name)}>\n"
      end

      def value_and_close_tag_with_nil_check
        "v.nil? ? \" nil=\\\"true\\\"/>\n\" : \"#{value_and_close_tag('v')}\""
      end

      def static_value_and_close_tag
        return " nil=\\\"true\\\"/>\n" if options[:static_value].nil?
        ">#{options[:static_value]}</#{format_name(name)}>\n"
      end

      def attributes_string
        return "" if !attributes || attributes.size == 0
        attributes.inject('') do |str, (key, value)|
          str << " #{key}=\\\"#{value}\\\""
        end
      end

      def condition_start
        "\#{\"" if conditional?
      end

      def condition_end
        return unless conditional?

        conditions = []

        if options[:partial]
          conditions << if options[:path] && options[:path].any?
            "field_hash[:'#{options[:path].join('.')}']"
          else
            "field_hash[:#{name.to_s.underscore}]"
          end
        end

        if options[:if]
          conditions << "object.#{options[:if]}"
        elsif options[:unless]
          conditions << "!object.#{options[:unless]}"
        end

        "\" if #{conditions.join(" && ")} }" if conditions.any?
      end

      def conditional?
        !!(options[:if] || options[:unless] || options[:partial])
      end
    end
  end
end