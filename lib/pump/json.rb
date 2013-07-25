require "pump/encoder"
require 'active_support/json/encoding'
require "oj"

module Pump
  class Json < Encoder

    private

    def compile_string
      <<-EOV
        def encode_single(object, options)
          json = {}
          #{build_string(encoder_config)}
          unless options[:exclude_root_in_json]
            json = { :'#{format_name(root_name)}' => json }
          end
          Oj.dump(json, :mode => :compat)
        end

        def encode_array(objects, options)
          Oj.dump(if options[:exclude_root_in_json]
            objects.map do |object|
              json = {}
              #{build_string(encoder_config)}
              json
            end
          else
            objects.map do |object|
              json = {}
              #{build_string(encoder_config)}
              { :'#{format_name(root_name)}' => json }
            end
          end, :mode => :compat)
        end
      EOV
    end

    def build_string(config, variable='json')
      config.inject("") do |str, config|
        build_key_value_pair(str, config, variable)
        str
      end
    end

    def build_key_value_pair(str, config, variable='json')
      name, method_name = config.keys.first, config.values.first
      if method_name.is_a?(Array) && !config.has_key?(:static_value)
        build_hash(str, name, method_name, config, variable)
      elsif config[:array]
        build_array(str, name, method_name, config, variable)
      else
        build_simple(str, name, method_name, config, variable)
      end
    end

    def build_hash(str, name, method_name, config, variable)
      str << "#{build_condition(config)}\n"
      str << "#{variable}[:'#{format_name(name)}'] = {}\n"
      str << build_string(method_name, "#{variable}[:'#{format_name(name)}']")
      str << "end\n" if build_condition(config)
    end

    def build_array(str, name, method_name, config, variable)
      str << "#{build_condition(config)}\n"
      str << "#{variable}[:'#{format_name(name)}'] = []\n"
      unless config.has_key?(:static_value)
        str << "object.#{method_name}.each do |object| "
        str << "#{variable}[:'#{format_name(name)}'] << {}\n"
        str << build_string(config[:array], "#{variable}[:'#{format_name(name)}'][-1]")
        str << "end\n"
      end
      str << "end\n" if build_condition(config)
    end

    def build_simple(str, name, method_name, config, variable)
      str << "#{variable}[:'#{format_name(name)}']=#{build_value(method_name, config)}#{build_condition(config)}\n"
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
      return name.to_s.dasherize if encoder_options[:json_key_style] == :dashes
      name.to_s.underscore
    end
  end
end