require "pump/dsl"

module Pump
  class Encoder
    attr_reader :root_name, :encoder_config, :encoder_options

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
      unless Array === encoder_config
        raise ArgumentError unless block_given?
        @encoder_options = encoder_config || {}
        @encoder_config = Pump::Dsl.new(&blk).config
      else
        @encoder_config  = encoder_config
        @encoder_options         = encoder_options
      end
      @root_name = root_name

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
      object.is_a?(Array) ? encode_array(object) : encode_single(object)
    end

    private

    def compile
      instance_eval(compile_string)
    end
  end
end