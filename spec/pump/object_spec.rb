require 'spec_helper'

class ObjectWithoutInclude

end

class ObjectWithInclude
  include Pump::Object

  def to_xml(options={})
    "<to_xml />"
  end

  def to_json(options={})
    "{to_json}"
  end
end

class ObjectWithIncludeAndPumps
  include Pump::Object

  add_pump :my_object do
    string  "name"
  end

  def name
    "MyName"
  end
end

class ObjectWithIncludeAndMultiplePumps
  include Pump::Object

  add_pump :my_object do
    string  "name"
  end

  add_pump :my_object, :sometimes do
    string  "name"
    integer  "age"
  end

  def name
    "MyName"
  end

  def age
    72
  end
end

describe Pump::Object do
  it "should not extend all objects by default" do
    ObjectWithoutInclude.respond_to?(:pumps).should eql(false)
  end

  context "when included" do
    subject { ObjectWithInclude }

    it "should add pumps class method" do
      subject.respond_to?(:pumps).should eql(true)
      subject.pumps.size.should eql(0)
    end

    it "should add pump_to_xml instance method" do
      subject.new.respond_to?(:pump_to_xml).should eql(true)
    end

    it "should add pump_to_json instance method" do
      subject.new.respond_to?(:pump_to_json).should eql(true)
    end

    it "should fall back to original to_xml on pump_to_xml" do
      subject.new.pump_to_xml.should eql("<to_xml />")
    end

    it "should fall back to original to_json on pump_to_xml" do
      subject.new.pump_to_json.should eql("{to_json}")
    end
  end

  context "when included with one encoder added" do
    subject { ObjectWithIncludeAndPumps }

    it "should add pump" do
      subject.pumps.size.should eql(1)
    end

    it "should return xml on pump_to_xml" do
      subject.new.pump_to_xml.should eql("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<my_object>\n  <name>MyName</name>\n</my_object>\n")
    end

    it "should return json on pump_to_json" do
      subject.new.pump_to_json.should eql("{\"my_object\":{\"name\":\"MyName\"}}")
    end
  end

  context "when included with multiple encoders added" do
    subject { ObjectWithIncludeAndMultiplePumps }

    it "should add pumps" do
      subject.pumps.size.should eql(2)
    end

    it "should return default xml on pump_to_xml" do
      subject.new.pump_to_xml.should eql("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<my_object>\n  <name>MyName</name>\n</my_object>\n")
    end

    it "should return special xml on set option" do
      subject.new.pump_to_xml(:set => :sometimes).should eql("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<my_object>\n  <name>MyName</name>\n  <age type=\"integer\">72</age>\n</my_object>\n")
    end

    it "should return default xml on pump_to_xml with unknown set option" do
      subject.new.pump_to_xml(:set => :unknown).should eql("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<my_object>\n  <name>MyName</name>\n</my_object>\n")
    end

    it "should return default json on pump_to_json" do
      subject.new.pump_to_json.should eql("{\"my_object\":{\"name\":\"MyName\"}}")
    end

    it "should return special json on set option" do
      subject.new.pump_to_json(:set => :sometimes).should eql("{\"my_object\":{\"name\":\"MyName\",\"age\":72}}")
    end

    it "should return default json on pump_to_json with unknown set option" do
      subject.new.pump_to_json(:set => :unknown).should eql("{\"my_object\":{\"name\":\"MyName\"}}")
    end

  end
end