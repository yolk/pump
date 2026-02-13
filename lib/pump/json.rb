require "pump/encoder"

require "oj"

module Pump
  class Json < Encoder

    private

    OJ_OPTIONS = {
      :mode => :custom,
      :second_precision => 0,
      :time_format => :xmlschema,
      :create_additions => false,
      :use_as_json => true
    }

    def compile_string
      main = build_main
      partial_main = build_main(:partial => true)

      <<-EOV
        def to_structs(object, options={})
          #{main}
          unless options[:exclude_root_in_json]
            json = { :'#{format_name(root_name)}' => json }
          end
          json
        end

        def encode_single(object, options)
          #{main}
          unless options[:exclude_root_in_json]
            json = { :'#{format_name(root_name)}' => json }
          end
          Oj.dump(json, OJ_OPTIONS)
        end

        def encode_partial_single(object, options)
          #{partial_main}
          unless options[:exclude_root_in_json]
            json = { :'#{format_name(root_name)}' => json }
          end
          Oj.dump(json, OJ_OPTIONS)
        end

        def encode_array(objects, options)
          Oj.dump(if options[:exclude_root_in_json]
            objects.map do |object|
              #{main}
              json
            end
          else
            objects.map do |object|
              #{main}
              { :'#{format_name(root_name)}' => json }
            end
          end, OJ_OPTIONS)
        end

        def encode_partial_array(objects, options)
          Oj.dump(if options[:exclude_root_in_json]
            objects.map do |object|
              #{partial_main}
              json
            end
          else
            objects.map do |object|
              #{partial_main}
              { :'#{format_name(root_name)}' => json }
            end
          end, OJ_OPTIONS)
        end
      EOV
    end

    def build_main(options={})
      <<-EOV
        field_hash = options[:fields]
        json = {}
        #{build_part(encoder_config, 'json', options)}
      EOV
    end

    def build_part(config, variable, options, path=[])
      config.inject(+"") do |str, config|
        build_key_value_pair(str, config, variable, options, path)
        str
      end
    end

    def build_key_value_pair(str, config, variable, options, path)
      name, method_name = config.keys.first, config.values.first
      condition = build_condition(name, config, options, path)
      if method_name.is_a?(Array) && !config.has_key?(:static_value)
        build_hash(str, name, method_name, config, variable, options, path, condition)
      elsif config[:array]
        build_array(str, name, method_name, config, variable, options, path, condition)
      else
        build_simple(str, name, method_name, config, variable, options, path, condition)
      end
    end

    def build_hash(str, name, method_name, config, variable, options, path, condition)
      str << "#{condition}\n" if condition
      str << "#{variable}[:'#{format_name(name)}'] = {}\n"
      str << build_part(method_name, "#{variable}[:'#{format_name(name)}']", options, path.dup << name)
      str << "end\n" if condition
    end

    def build_array(str, name, method_name, config, variable, options, path, condition)
      str << "#{condition}\n" if condition
      str << "#{variable}[:'#{format_name(name)}'] = []\n"
      unless config.has_key?(:static_value)
        str << "object.#{method_name}.each do |object| "
        str << "#{variable}[:'#{format_name(name)}'] << {}\n"
        str << build_part(config[:array], "#{variable}[:'#{format_name(name)}'][-1]", options, path.dup << name)
        str << "end\n"
      end
      str << "end\n" if condition
    end

    def build_simple(str, name, method_name, config, variable, options, path, condition)
      str << "#{variable}[:'#{format_name(name)}']=#{build_value(method_name, config)}#{condition}\n"
    end

    def build_value(method_name, config)
      return config[:static_value].inspect if config.has_key?(:static_value)
      "object.#{method_name}"
    end

    def build_condition(name, config, options, path)
      conditions = []
      conditions << build_partial_condition(name, path) if options[:partial]

      if config[:if]
        conditions << "object.#{config[:if]}"
      elsif config[:unless]
        conditions << "!object.#{config[:unless]}"
      end

      conditions.any? ? " if #{conditions.join(" && ")} " : nil
    end

    def build_partial_condition(name, path)
      if path.any?
        "field_hash[:'#{path.join('.')}']"
      else
        "field_hash[:#{name.to_s.underscore}]"
      end
    end

    def format_name(name)
      return name.to_s.dasherize if encoder_options[:json_key_style] == :dashes
      name.to_s.underscore
    end
  end
end
