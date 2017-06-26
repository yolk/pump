require File.dirname(__FILE__) + '/../lib/pump.rb'

require 'rspec/its'

require 'active_support/json'
ActiveSupport::JSON::Encoding.use_standard_json_time_format = true
ActiveSupport::JSON::Encoding.time_precision = 0

XML_INSTRUCT = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
  config.backtrace_exclusion_patterns = [/rspec\/(core|expectations)/]
end
