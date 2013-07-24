require "pump/dsl"
require "oj"

module Pump
  class Json

    attr_reader :root_name, :config, :options

    def initialize(root_name, config=nil, options={}, &blk)
      unless Array === config
        raise ArgumentError unless block_given?
        @options = config || {}
        @config = Pump::Dsl.new(&blk).config
      else
        @config    = config
        @options   = options
      end
      @root_name = root_name

      compile
    end

    def encode(object)
      data = if Array === object
        object.map{|obj| encode_single(obj)}
      else
        encode_single(object)
      end
      Oj.dump(data)
    end

    private

    def compile
      instance_eval(compile_string)
    end

    def compile_string
      <<-EOV
        def encode_single(object)
          json = {
            #{build_direct_string(all_config_for_direct)}
          }
          #{build_string(all_config_for_indirect)}
          { '#{format_name(root_name)}' => json }
        end
      EOV
    end

    def all_config_for_direct
      config.find_all{|it|
        !it[:if] && !it[:unless] && !it[:array] && !it.values.first.is_a?(Array)
      }
    end

    def all_config_for_indirect
      config.find_all{|it|
        it[:if] || it[:unless] || it[:array] || it.values.first.is_a?(Array)
      }
    end

    def build_direct_string(config)
      config.inject([]) do |str, config|
        build_direct_key_value_pair(str, config)
        str
      end.join(",")
    end

    def build_string(config, variable='json')
      config.inject("") do |str, config|
        build_key_value_pair(str, config, variable)
        str
      end
    end

    def build_direct_key_value_pair(str, config)
      name, method_name = config.keys.first, config.values.first
      str << "'#{format_name(name)}'=>#{build_value(method_name, config)}"
    end

    def build_key_value_pair(str, config, variable='json')
      name, method_name = config.keys.first, config.values.first
      if method_name.is_a?(Array) && !config.has_key?(:static_value)
        str << "#{build_condition(config)}\n#{variable}['#{format_name(name)}'] = {}\n"
        str << build_string(method_name, "#{variable}['#{format_name(name)}']")
        str << "end\n" if build_condition(config)
      elsif config[:array]
        str << "#{build_condition(config)}\n#{variable}['#{format_name(name)}'] = []\n"
        unless config.has_key?(:static_value)
          str << "object.#{method_name}.each do |object| "
          str << "#{variable}['#{format_name(name)}'] << {}\n"
          str << build_string(config[:array], "#{variable}['#{format_name(name)}'][-1]")
           str << "end\n"
        end
        str << "end\n" if build_condition(config)
      else
        str << "#{variable}['#{format_name(name)}']=#{build_value(method_name, config)}#{build_condition(config)}\n"
      end
    end

    def build_value(method_name, config)
      return config[:static_value].inspect if config.has_key?(:static_value)
      "object.#{method_name}"
    end

    def build_condition(config)
      if config[:if]
        " if object.#{config[:if]}"
      elsif config[:unless]
        " unless object.#{config[:unless]}"
      end
    end

    def format_name(name)
      return name if options[:underscore] == false
      name.to_s.underscore
    end
  end
end