require "pump/xml/tag"
require "pump/xml/value"
require "pump/xml/tag_array"

module Pump
  class Xml
    attr_reader :root_tag_name, :tag_config, :options

    def initialize(root_tag_name, tag_config, options={})
      @root_tag_name = root_tag_name
      @tag_config    = tag_config
      @options       = options

      compile
    end

    def serialize(object)
      Array === object ? serialize_array(object) : serialize_single(object)
    end

    private

    def compile
      instance_eval(compile_string)
    end

    def compile_string
      <<-EOV
        def serialize_single(object)
          "#{Tag.new(root_tag_name, {}, sub_tags, tag_options)}"
        end

        def serialize_array(objects)
          "#{TagArray.new(root_tag_name, {}, sub_tags, tag_options)}"
        end
      EOV
    end

    def sub_tags
      tag_config.map do |options|
        tag_name, method_name = options.keys.first, options.values.first
        Tag.new(tag_name, options[:attributes], Value.new(method_name), options)
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