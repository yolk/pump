require "pump/xml/tag"
require "pump/xml/value"
require "pump/xml/tag_array"
require "pump/xml/dsl"
require 'active_support/core_ext/string/inflections'

module Pump
  class Xml
    attr_reader :root_tag_name, :tag_config, :options

    def initialize(root_tag_name, tag_config, options={})
      @root_tag_name = root_tag_name
      @tag_config    = tag_config
      @options       = options

      compile
    end

    def encode(object)
      Array === object ? encode_array(object) : encode_single(object)
    end

    private

    def compile
      instance_eval(compile_string)
    end

    def compile_string
      <<-EOV
        def encode_single(object)
          "#{Tag.new(root_tag_name, {}, sub_tags, tag_options)}"
        end

        def encode_array(objects)
          "#{TagArray.new(root_tag_name, {}, sub_tags, tag_options)}"
        end
      EOV
    end

    def sub_tags
      tag_config.map do |config|
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
      {:instruct => add_instruct?, :extra_indent => options[:extra_indent], :array_root => options[:array_root] }
    end

    def add_instruct?
      options.has_key?(:instruct) ? options[:instruct] : true
    end
  end
end