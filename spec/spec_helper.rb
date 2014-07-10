require File.dirname(__FILE__) + '/../lib/pump.rb'

require 'rspec/its'

XML_INSTRUCT = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
  config.backtrace_exclusion_patterns = [/rspec\/(core|expectations)/]
end
