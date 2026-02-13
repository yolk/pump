require "pump/encoder"
require 'active_support/core_ext/string/inflections'

module Pump
  class Xml < Pump::Encoder

    private

    def compile_string
      <<-EOV
        def to_structs(object, options)
          "#{Tag.new(root_name, {}, sub_tags, tag_options.merge(instruct: false))}"
        end

        def encode_single(object, options)
          "#{Tag.new(root_name, {}, sub_tags, tag_options)}"
        end

        def encode_array(objects, options)
          "#{TagArray.new(root_name, {}, sub_tags, tag_options)}"
        end

        def encode_partial_single(object, options)
          field_hash = options[:fields]
          "#{Tag.new(root_name, {}, sub_tags(true), tag_options)}"
        end

        def encode_partial_array(objects, options)
          field_hash = options[:fields]
          "#{TagArray.new(root_name, {}, sub_tags(true), tag_options)}"
        end
      EOV
    end

    def sub_tags(partial=false)
      encoder_config.map do |config|
        build_tag(config, partial)
      end
    end

    def build_tag(config, partial, path=[])
      tag_name, method_name = config.keys.first, config.values.first
      attrs = config[:attributes]
      options = config.merge({:xml_key_style => encoder_options[:xml_key_style], :partial => partial, :path => path})
      if method_name.is_a?(Array)
        Tag.new(tag_name, attrs, method_name.map{|conf| build_tag(conf, partial, path.dup << tag_name) }, options)
      elsif config[:array]
        options.merge!(:array_method => method_name, :array_root => tag_name)
        child_root = config[:child_root] || tag_name.to_s.singularize
        tags = config[:array].map{|conf| build_tag(conf, partial, path.dup << tag_name) }
        TagArray.new(child_root, attrs, tags, options)
      else
        Tag.new(tag_name, attrs, Value.new(method_name), options)
      end
    end

    def tag_options
      {
        :instruct => add_instruct?, :extra_indent => encoder_options[:extra_indent],
        :array_root => encoder_options[:array_root],
        :xml_key_style => encoder_options[:xml_key_style]
      }
    end

    def add_instruct?
      encoder_options.has_key?(:instruct) ? encoder_options[:instruct] : true
    end

    VALID_CHAR = [
      0x9, 0xA, 0xD,
      (0x20..0xD7FF),
      (0xE000..0xFFFD),
      (0x10000..0x10FFFF)
    ]

    VALID_XML_CHARS = Regexp.new('\A['+
      VALID_CHAR.map { |item|
        case item
        when 0.class
          [item].pack('U').force_encoding('utf-8')
        when Range
          [item.first, '-'.ord, item.last].pack('UUU').force_encoding('utf-8')
        end
      }.join +
    ']*\Z')

    def remove_ilegal_chars(string)
      return string if !string.is_a?(String) || string =~ VALID_XML_CHARS
      out = +""
      string.chars.each do |c|
        case c.ord
        when *VALID_CHAR
          out << c
        end
      end
      out
    end
  end
end

require "pump/xml/tag"
require "pump/xml/value"
require "pump/xml/tag_array"
