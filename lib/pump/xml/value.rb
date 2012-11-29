require 'pump/xml/node'

module Pump
  class Xml
    class Value < Node
      attr_accessor :options

      def plain
        "object.#{name}"
      end

      def to_s(plain_path=nil)
        "\#{#{plain_path || plain}#{'.to_s.encode(:xml => :text)' unless options[:skip_encoding]}}"
      end
    end
  end
end