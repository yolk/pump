module Pump
  class Xml
    class Dsl
      def initialize(&blk)
        raise ArgumentError unless block_given?
        instance_eval(&blk)
      end

      def config
        @config ||= []
      end

      private

      def tag(name, options={}, &blk)
        method = if block_given?
          self.class.new(&blk).config
        else
          options.delete(:from) || (name.to_s =~ /-/ ? name.to_s.gsub('-', '_').to_sym : name)
        end
        config << ({ name => method }).merge(options)
      end
      alias_method :string, :tag

      def integer(name, options={})
        with_type('integer', name, options)
      end

      def float(name, options={})
        with_type('float', name, options)
      end

      def boolean(name, options={})
        with_type('boolean', name, options)
      end

      def date(name, options={})
        with_type('date', name, options)
      end

      def datetime(name, options={})
        options[:typecast] = :xmlschema unless options.has_key?(:typecast)
        with_type('datetime', name, options)
      end
      alias_method :time, :datetime

      def with_type(type, name, options)
        (options[:attributes] ||= {}).merge!({:type => type})
        options[:xmlsafe] = true unless options.has_key?(:xmlsafe)
        tag(name, options)
      end

      def array(name, options={}, &blk)
        options[:array] = self.class.new(&blk).config
        tag(name, options)
      end
    end
  end
end