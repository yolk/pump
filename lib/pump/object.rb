require 'pump/collection'
require 'pump/xml'
require 'active_support/concern'

module Pump
  module Object
    extend ActiveSupport::Concern

    def pump_to_xml(options={})
      encoder = self.class.pumps.get(options[:set], :xml)
      if encoder
        encoder.encode(self)
      else
        to_xml(options)
      end
    end

    def pump_to_json(options={})
      encoder = self.class.pumps.get(options[:set], :json)
      if encoder
        encoder.encode(self)
      else
        to_json(options)
      end
    end

    module ClassMethods
      def pumps
        @pumps ||= Pump::Collection.new
      end

      def add_pump(name, set=nil, options={}, &block)
        pumps.add(set, :xml, Pump::Xml.new(name, options, &block))
        pumps.add(set, :json, Pump::Json.new(name, options, &block))
      end
    end
  end
end