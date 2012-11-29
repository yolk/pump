require 'spec_helper'

describe Pump::Xml do
  describe ".new" do
    it "requires two parameters" do
      lambda{ Pump::Xml.new }.should raise_error(ArgumentError)
      lambda{ Pump::Xml.new('record') }.should raise_error(ArgumentError)
      lambda{ Pump::Xml.new('record', []) }.should_not raise_error
    end
  end

  describe "#serialize" do
    let(:person) { Struct.new(:name, :age).new('Benny', 9) }
    let(:xml) { Pump::Xml.new('person', [{:name => :name}]) }

    it "requires one object" do
      lambda{ xml.serialize }.should raise_error(ArgumentError)
      lambda{ xml.serialize(person) }.should_not raise_error
    end

    it "returns xml string" do
      xml.serialize(person).should eql("#{XML_INSTRUCT}<person>\n  <name>Benny</name>\n</person>")
    end

    context "with attribute" do
      let(:xml) do
        Pump::Xml.new('person', [
          {:name => :name},
          {:age => :age, :attributes => {:type => :integer}}
        ])
      end

      it do
        xml.serialize(person).should eql("#{XML_INSTRUCT}<person>\n  <name>Benny</name>\n  <age type=\"integer\">9</age>\n</person>")
      end

    end

    context "with blank name" do
      let(:person) { Struct.new(:name, :age).new('', 9) }

      it do
        xml.serialize(person).should eql("#{XML_INSTRUCT}<person>\n  <name/>\n</person>")
      end
    end

    context "with nil name" do
      let(:person) { Struct.new(:name, :age).new(nil, 9) }

      it do
        xml.serialize(person).should eql("#{XML_INSTRUCT}<person>\n  <name/>\n</person>")
      end

      context "and with :nil_check => true" do
        let(:xml) { Pump::Xml.new('person', [{:name => :name, :nil_check => true}]) }

        it do
          xml.serialize(person).should eql("#{XML_INSTRUCT}<person>\n  <name nil=\"true\"/>\n</person>")
        end
      end
    end
  end
end