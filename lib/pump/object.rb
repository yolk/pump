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
        self.to_xml(options)
      end
    end

    module ClassMethods
      def pumps
        @pumps ||= Pump::Collection.new
      end

      def add_pump(name, set=nil, options={}, &block)
        pumps.add(set, :xml, Pump::Xml.new(name, options, &block))
      end
    end
  end

  class Collection
    def initialize
      @pumps = {:xml => {}}
    end

    def add(set, format, value)
      @pumps[format][set || :default] = value
    end

    def get(set, format)
      @pumps[format][set] || @pumps[format][:default]
    end

    def size
      @pumps.values.map(&:size).inject(0) {|sum, it| sum += it; it}
    end
  end
end