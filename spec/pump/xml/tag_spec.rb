require 'spec_helper'

describe Pump::Xml::Tag do
  describe ".new" do
    it "requires one parameter" do
      lambda{ Pump::Xml::Tag.new }.should raise_error(ArgumentError)
      lambda{ Pump::Xml::Tag.new(0) }.should_not raise_error
    end
  end
end