require "pump/xml/tag"
require "pump/xml/value"
require "pump/xml/tag_array"
require "pump/xml/dsl"
require 'active_support/core_ext/string/inflections'

module Pump
  class Xml

    attr_reader :root_tag_name, :tag_config, :options

    # Creates a new XML-encoder with a root tag named after +root_tag_name+.
    #
    # @example Create a simple encoder for a person with a name attribute:
    #   Pump::Xml.new :person do
    #     tag :name
    #   end
    #
    # @example Create the same without usage of the DSL:
    #   Pump::Xml.new :person, [{:name => :name}]
    #
    # @example Create the same but without the xml instruct
    #   Pump::Xml.new :person, :instruct => false do
    #     tag :name
    #   end
    #
    # @example The same again without DSL:
    #
    #   Pump::Xml.new :person, [{:name => :name}], :instruct => false
    #
    # @param [String, Symbol] root_tag_name     the name of the used root tag
    # @param [Array<Hash>] tag_config           optional config for all tags
    # @param [Hash] options                     optional options for the whole encoder
    # @yield an optional block to create the encoder with the Pump::Xml::Dsl
    #
    # @return [self]
    def initialize(root_tag_name, tag_config=nil, options={}, &blk)
      unless Array === tag_config
        raise ArgumentError unless block_given?
        @options = tag_config || {}
        @tag_config = Dsl.new(&blk).config
      else
        @tag_config    = tag_config
        @options       = options
      end
      @root_tag_name = root_tag_name

      compile
    end

    # Encode a object or an array of objects to an XML-string.
    #
    # @param [Object, Array<Object>] object object or an array of objects to
    #    encode to XML. The only requirement: The given objects must respond
    #    to all methods configured during initalization of the Pump::Xml instance.
    #
    # @return [String]
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