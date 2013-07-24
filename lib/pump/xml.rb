require "pump/encoder"
require 'active_support/core_ext/string/inflections'

module Pump
  class Xml < Pump::Encoder

    private

    def compile_string
      <<-EOV
        def encode_single(object, options)
          "#{Tag.new(root_name, {}, sub_tags, tag_options)}"
        end

        def encode_array(objects, options)
          "#{TagArray.new(root_name, {}, sub_tags, tag_options)}"
        end
      EOV
    end

    def sub_tags
      encoder_config.map do |config|
        build_tag(config)
      end
    end

    def build_tag(config)
      tag_name, method_name = config.keys.first, config.values.first
      attrs = config[:attributes]
      if method_name.is_a?(Array)
        Tag.new(tag_name, attrs, method_name.map{|conf| build_tag(conf) }, config)
      elsif config[:array]
        config.merge!(:array_method => method_name, :array_root => tag_name)
        TagArray.new(config[:child_root] || tag_name.to_s.singularize, attrs, config[:array].map{|conf| build_tag(conf) }, config)
      else
        Tag.new(tag_name, attrs, Value.new(method_name), config)
      end
    end

    def tag_options
      {:instruct => add_instruct?, :extra_indent => encoder_options[:extra_indent], :array_root => encoder_options[:array_root] }
    end

    def add_instruct?
      encoder_options.has_key?(:instruct) ? encoder_options[:instruct] : true
    end
  end
end

require "pump/xml/tag"
require "pump/xml/value"
require "pump/xml/tag_array"