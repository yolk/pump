require 'pump/xml/node'

module Pump
  class Xml
    class Value < Node
      attr_accessor :options

      def plain
        "object.#{name}"
      end

      def to_s(plain_path=nil)
        "\#{#{remove_ilegal_chars}#{plain_path || plain}#{cast}}"
      end

      private

      def cast
        if options[:typecast]
          ".#{options[:typecast]}"
        elsif !options[:xmlsafe]
          '.to_s.encode(:xml => :text)'
        end
      end

      def remove_ilegal_chars
        "remove_ilegal_chars " if !options[:typecast] && !options[:xmlsafe]
      end
    end
  end
end