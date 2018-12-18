require "pump/dsl"

module Pump
  class Encoder
    attr_reader :root_name, :encoder_config, :encoder_options, :base

    # Creates a new XML-encoder with a root tag named after +root_name+.
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
    # @param [String, Symbol] root_name         the name of the used root tag
    # @param [Array<Hash>] encoder_config       optional config for all tags
    # @param [Hash] encoder_options             optional encoder_options for the whole encoder
    # @yield an optional block to create the encoder with the Pump::Dsl
    #
    # @return [self]
    def initialize(root_name, encoder_config=nil, encoder_options={}, &blk)
      if encoder_config.is_a?(Array)
        @encoder_config  = encoder_config
        @encoder_options = encoder_options || {}
      else
        raise ArgumentError unless block_given?
        @encoder_options = encoder_config || {}
        @encoder_config = Pump::Dsl.new(&blk).config
      end
      @root_name = root_name
      merge_base

      compile_field_map
      compile
    end

    # Encode a object or an array of objects to an formatted string.
    #
    # @param [Object, Array<Object>] object object or an array of objects to
    #    encode to XML or JSON. The only requirement: The given objects must respond
    #    to all methods configured during initalization of the Pump::Xml or Pump::JSON instance.
    #
    # @return [String]
    def encode(object, options={})
      object = object.to_a if defined?(ActiveRecord::Relation) && object.is_a?(ActiveRecord::Relation)
      fields_to_hash(options)
      if object.is_a?(Array)
        if options[:fields]
          encode_partial_array(object, options)
        else
          encode_array(object, options)
        end
      elsif options[:fields]
        encode_partial_single(object, options)
      else
        encode_single(object, options)
      end
    end

    private

    def compile
      compile_string && instance_eval(compile_string)
    end

    def compile_string;end

    def compile_field_map
      instance_eval("@fields_map = { #{compile_string_fields_map} }")
    end

    def compile_string_fields_map
      encoder_config.map do |config|
        config.keys.first
      end.inject([]) do |array, name|
        underscores = name.to_s.underscore
        dashes = name.to_s.dasherize
        array << "'#{dashes}' => true" if dashes != underscores
        array << "'#{underscores}' => true"
      end.join(',')
    end

    def merge_base
      return unless @encoder_options[:base]
      @base = @encoder_options.delete(:base)

      merge_base_config
      merge_base_options
    end

    def merge_base_config
      original_encoder_config = @encoder_config
      @encoder_config = base.encoder_config.dup
      original_encoder_config.each do |it|
        key = it.keys.first
        index = @encoder_config.index{|config| config.keys.first == key}
        if index
          @encoder_config[index] = it
        else
          @encoder_config.push(it)
        end
      end
    end

    def merge_base_options
      encoder_options.merge!(base.encoder_options) { |key, v1, v2| v1 }
    end

    def fields_to_hash(options)
      return unless options[:fields]
      options[:fields] = options[:fields].inject({}) do |hash, name|
        hash[name.to_s.underscore.to_sym] = true if @fields_map[name.to_s]
        hash
      end
    end
  end
end
