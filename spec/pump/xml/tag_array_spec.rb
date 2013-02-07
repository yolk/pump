require 'spec_helper'

describe Pump::Xml::TagArray do
  describe ".new" do
    it "requires one parameter" do
      lambda{ Pump::Xml::TagArray.new }.should raise_error(ArgumentError)
      lambda{ Pump::Xml::TagArray.new('tag') }.should_not raise_error
    end
  end
end