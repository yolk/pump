require 'spec_helper'

class ObjectWithoutInclude;end

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

class ObjectWithIncludeAndMultiplePumpsWithInheritance
  include Pump::Object

  add_pump :my_object do
    string  "name"
    string "role"
  end

  add_pump :my_object, :restricted, :base => :default do
    integer  "age"
    string "role", :static_value => "basic_role"
  end

  def name
    "MyName"
  end

  def role
    "my_role"
  end

  def age
    72
  end
end

describe Pump::Object do
  it "should not extend all objects by default" do
    expect(ObjectWithoutInclude.respond_to?(:pumps)).to eql(false)
  end

  context "when included" do
    subject { ObjectWithInclude }

    it "should add pumps class method" do
      expect(subject.respond_to?(:pumps)).to eql(true)
      expect(subject.pumps.size).to eql(0)
    end

    it "should add pump_to_xml instance method" do
      expect(subject.new.respond_to?(:pump_to_xml)).to eql(true)
    end

    it "should add pump_to_json instance method" do
      expect(subject.new.respond_to?(:pump_to_json)).to eql(true)
    end

    it "should fall back to original to_xml on pump_to_xml" do
      expect(subject.new.pump_to_xml).to eql("<to_xml />")
    end

    it "should fall back to original to_json on pump_to_xml" do
      expect(subject.new.pump_to_json).to eql("{to_json}")
    end
  end

  context "when included with one encoder added" do
    subject { ObjectWithIncludeAndPumps }

    it "should add pump" do
      expect(subject.pumps.size).to eql(1)
    end

    it "should return xml on pump_to_xml" do
      expect(subject.new.pump_to_xml).to eql("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<my-object>\n  <name>MyName</name>\n</my-object>\n")
    end

    it "should return json on pump_to_json" do
      expect(subject.new.pump_to_json).to eql("{\"my_object\":{\"name\":\"MyName\"}}")
    end

    it "should pass down options to encoder" do
      expect(subject.new.pump_to_json(:exclude_root_in_json => true)).to eql("{\"name\":\"MyName\"}")
    end
  end

  context "when included with multiple encoders added" do
    subject { ObjectWithIncludeAndMultiplePumps }

    it "should add pumps" do
      expect(subject.pumps.size).to eql(2)
    end

    it "should return default xml on pump_to_xml" do
      expect(subject.new.pump_to_xml).to eql("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<my-object>\n  <name>MyName</name>\n</my-object>\n")
    end

    it "should return special xml on set option" do
      expect(subject.new.pump_to_xml(:set => :sometimes)).to eql("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<my-object>\n  <name>MyName</name>\n  <age type=\"integer\">72</age>\n</my-object>\n")
    end

    it "should return default xml on pump_to_xml with unknown set option" do
      expect(subject.new.pump_to_xml(:set => :unknown)).to eql("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<my-object>\n  <name>MyName</name>\n</my-object>\n")
    end

    it "should return default json on pump_to_json" do
      expect(subject.new.pump_to_json).to eql("{\"my_object\":{\"name\":\"MyName\"}}")
    end

    it "should return special json on set option" do
      expect(subject.new.pump_to_json(:set => :sometimes)).to eql("{\"my_object\":{\"name\":\"MyName\",\"age\":72}}")
    end

    it "should return default json on pump_to_json with unknown set option" do
      expect(subject.new.pump_to_json(:set => :unknown)).to eql("{\"my_object\":{\"name\":\"MyName\"}}")
    end
  end

  context "when included with multiple encoders added with inheritance" do
    subject { ObjectWithIncludeAndMultiplePumpsWithInheritance }

    it "should add pumps" do
      expect(subject.pumps.size).to eql(2)
    end

    it "should return default xml on pump_to_xml" do
      expect(subject.new.pump_to_xml).to eql("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<my-object>\n  <name>MyName</name>\n  <role>my_role</role>\n</my-object>\n")
    end

    it "should return default json on pump_to_json" do
      expect(subject.new.pump_to_json).to eql("{\"my_object\":{\"name\":\"MyName\",\"role\":\"my_role\"}}")
    end

    it "should return special inherited xml on pump_to_xml(:set => :restricted)" do
      expect(subject.new.pump_to_xml(:set => :restricted)).to eql("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<my-object>\n  <name>MyName</name>\n  <role>basic_role</role>\n  <age type=\"integer\">72</age>\n</my-object>\n")
    end

    it "should return special inherited json on pump_to_json(:set => :restricted)" do
      expect(subject.new.pump_to_json(:set => :restricted)).to eql("{\"my_object\":{\"name\":\"MyName\",\"role\":\"basic_role\",\"age\":72}}")
    end
  end
end