require "pump/xml/tag"
require "pump/xml/value"
require "pump/xml/tag_array"

module Pump
  class Xml
    def initialize(root_name, tags, options={})
      @root_name = root_name
      @tags = tags
      @options = options
      build
    end

    private

    def build
      self.instance_eval build_string
    end

    def build_string
      root_node = Tag.new(@root_name, {}, tags, tag_options)
      array_root_node = TagArray.new(@root_name, {}, tags, tag_options)
      <<-EOV
        def serialize(object)
          Array === object ? serialize_array(object) : serialize_single(object)
        end

        def serialize_single(object)
          "#{root_node}"
        end

        def serialize_array(objects)
          "#{array_root_node}"
        end
      EOV
    end

    def tags
      @tags.map do |options|
        tag_name, method_name = options.keys.first, options.values.first
        Tag.new(tag_name, options[:attributes], Value.new(method_name), options)
      end
    end

    def tag_options
      {:instruct => add_instruct?, :extra_indent => @options[:extra_indent] }
    end

    def add_instruct?
      @options.has_key?(:instruct) ? @options[:instruct] : true
    end
  end
end