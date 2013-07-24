require 'spec_helper'

class Array
  def to_xml(options={})
    "<Array#to_xml />"
  end

  def to_json(options={})
    "{Array#to_json}"
  end
end

class ArrayObjectWithoutInclude
end

class ArrayObjectWithInclude
  include Pump::Object
end

class ArrayObject
  include Pump::Object

  add_pump 'array-object' do
    string :name
  end

  add_pump 'array-object', :with_age do
    string :name
    integer :age
  end

  def name
    "Tintin"
  end

  def age
    27
  end
end

describe Pump::Array do
  it "should extend ::Array by default with pump_to_xml" do
    [].respond_to?(:pump_to_xml).should eql(true)
  end

  it "should extend ::Array by default with pump_to_json" do
    [].respond_to?(:pump_to_json).should eql(true)
  end

  context "with objects without include" do
    subject{ [ArrayObjectWithoutInclude.new] }

    it "should return default to_xml" do
      subject.pump_to_xml.should eql(subject.to_xml)
    end

    it "should return default to_json" do
      subject.pump_to_json.should eql(subject.to_json)
    end
  end

  context "with objects with include but without encoders" do
    subject{ [ArrayObjectWithInclude.new] }

    it "should return default to_xml" do
      subject.pump_to_xml.should eql(subject.to_xml)
    end

    it "should return default to_json" do
      subject.pump_to_json.should eql(subject.to_json)
    end
  end

  context "with objects with include and encoders" do
    subject{ [ArrayObject.new] }

    it "should encode with default encoder" do
      subject.pump_to_xml.should eql("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<array-objects type=\"array\">\n  <array-object>\n    <name>Tintin</name>\n  </array-object>\n</array-objects>\n")
    end

    it "should encode with specified encoder" do
      subject.pump_to_xml(:set => :with_age).should eql("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<array-objects type=\"array\">\n  <array-object>\n    <name>Tintin</name>\n    <age type=\"integer\">27</age>\n  </array-object>\n</array-objects>\n")
    end

    it "should encode with default encoder on unknown set" do
      subject.pump_to_xml(:set => :bla).should eql("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<array-objects type=\"array\">\n  <array-object>\n    <name>Tintin</name>\n  </array-object>\n</array-objects>\n")
    end

    it "should encode json with default encoder" do
      subject.pump_to_json.should eql("[{\"array_object\":{\"name\":\"Tintin\"}}]")
    end

    it "should encode json with specified encoder" do
      subject.pump_to_json(:set => :with_age).should eql("[{\"array_object\":{\"name\":\"Tintin\",\"age\":27}}]")
    end

    it "should encode json with default encoder on unknown set" do
      subject.pump_to_json(:set => :bla).should eql("[{\"array_object\":{\"name\":\"Tintin\"}}]")
    end
  end
end