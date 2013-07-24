module Pump
  module Array
    def pump_to_xml(options={})
      encoder = get_pump_encoder(options[:set], :xml)
      return to_xml(options) unless encoder
      encoder.encode(self, options)
    end

    def pump_to_json(options={})
      encoder = get_pump_encoder(options[:set], :json)
      return to_json(options) unless encoder
      encoder.encode(self, options)
    end

    private

    def get_pump_encoder(set, format)
      return if empty? || !first.class.respond_to?(:pumps)
      first.class.pumps.get(set, format)
    end
  end
end

class ::Array
  include Pump::Array
end