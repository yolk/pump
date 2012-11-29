require "pump/xml/tag"
require "pump/xml/value"

module Pump
  class Xml
    def initialize(root_name, tags)
      @root_name = root_name
      @tags = tags
      build
    end

    def serialize(object)
      # "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<#{@root_name}>\n  <name>#{record.name}</name>\n</#{@root_name}>"
    end

    private

    def build
      self.instance_eval build_string
    end

    def build_string
      root_node = Tag.new(@root_name, {}, tags, {:instruct => true})
      <<-EOV
        def serialize(object)
          "#{root_node}"
        end
      EOV
    end

    def tags
      @tags.map do |options|
        tag_name, method_name = options.keys.first, options.values.first
        Tag.new(tag_name, options[:attributes], Value.new(method_name), options)
      end
    end
  end
end