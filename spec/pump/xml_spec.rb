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
    let(:person) { Struct.new(:name, :age, :last_name).new('Benny', 9, 'Hellman') }
    let(:xml) { Pump::Xml.new('person', [{:name => :name}]) }

    it "requires one object" do
      lambda{ xml.serialize }.should raise_error(ArgumentError)
      lambda{ xml.serialize(person) }.should_not raise_error
    end

    it "returns xml string" do
      xml.serialize(person).should eql("#{XML_INSTRUCT}<person>\n  <name>Benny</name>\n</person>")
    end

    context "with array to serialize" do

      context "with one entry" do
        let(:people) { [person] }

        it "returns xml string" do
          xml.serialize(people).should eql("#{XML_INSTRUCT}<people type=\"array\">\n  <person>\n    <name>Benny</name>\n  </person>\n</people>")
        end
      end

      context "with multiple entries" do
        let(:people) { [person, Struct.new(:name, :age).new('Carlo', 5)] }

        it "returns xml string" do
          xml.serialize(people).should eql("#{XML_INSTRUCT}<people type=\"array\">\n  <person>\n    <name>Benny</name>\n  </person>\n  <person>\n    <name>Carlo</name>\n  </person>\n</people>")
        end
      end

      context "with empty array" do
        let(:people) { [] }

        it "returns xml string" do
          xml.serialize(people).should eql("#{XML_INSTRUCT}<people type=\"array\" />")
        end
      end

      context "with no instruct" do
        let(:xml) { Pump::Xml.new('person', [{:name => :name}], :instruct => false) }
        let(:people) { [] }

        it "returns xml string" do
          xml.serialize(people).should eql("<people type=\"array\" />")
        end
      end

      context "with extra_indent" do
        let(:people) { [person] }
        let(:xml) { Pump::Xml.new('person', [{:name => :name}], :instruct => false, :extra_indent => 1) }

        it "returns xml string" do
          xml.serialize(people).should eql("  <people type=\"array\">\n    <person>\n      <name>Benny</name>\n    </person>\n  </people>")
        end
      end

      context "with array_root" do
        let(:people) { [person] }
        let(:xml) { Pump::Xml.new('person', [{:name => :name}], :instruct => false, :array_root => "personas") }

        it "returns xml string" do
          xml.serialize(people).should eql("<personas type=\"array\">\n  <person>\n    <name>Benny</name>\n  </person>\n</personas>")
        end
      end
    end

    context "with no instruct" do
      let(:xml) { Pump::Xml.new('person', [{:name => :name}], :instruct => false) }

      it "returns xml string" do
        xml.serialize(person).should eql("<person>\n  <name>Benny</name>\n</person>")
      end
    end

    context "with extra_indent" do
      let(:xml) { Pump::Xml.new('person', [{:name => :name}], :instruct => false, :extra_indent => 1) }

      it "returns xml string" do
        xml.serialize(person).should eql("  <person>\n    <name>Benny</name>\n  </person>")
      end
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

    context "with multiple attrubutes" do
      let(:xml) { Pump::Xml.new('person', [{:name => :name}, {:age => :age}]) }

      it "returns xml string" do
        xml.serialize(person).should eql("#{XML_INSTRUCT}<person>\n  <name>Benny</name>\n  <age>9</age>\n</person>")
      end
    end

    context "with renamed attrubutes" do
      let(:xml) { Pump::Xml.new('person', [{"last-name" => :last_name}]) }

      it "returns xml string" do
        xml.serialize(person).should eql("#{XML_INSTRUCT}<person>\n  <last-name>Hellman</last-name>\n</person>")
      end
    end

    context "with date attribute" do
      let(:person) { Struct.new(:at).new(Date.new(2013, 2, 7)) }
      let(:xml) { Pump::Xml.new('person', [{:at => :at, :attributes => {:type => 'date'}}]) }

      it "returns xml string" do
        xml.serialize(person).should eql("#{XML_INSTRUCT}<person>\n  <at type=\"date\">2013-02-07</at>\n</person>")
      end
    end

    context "with datetime attribute" do
      let(:person) { Struct.new(:at).new(Time.new(2013, 2, 7, 0, 0, 0)) }
      let(:xml) { Pump::Xml.new('person', [{:at => :at, :typecast => :xmlschema, :attributes => {:type => 'datetime'}}]) }

      it "returns xml string" do
        xml.serialize(person).should eql("#{XML_INSTRUCT}<person>\n  <at type=\"datetime\">2013-02-07T00:00:00+01:00</at>\n</person>")
      end

      context "but nil" do
        let(:person) { Struct.new(:at).new(nil) }

        it "returns xml string" do
          xml.serialize(person).should eql("#{XML_INSTRUCT}<person>\n  <at type=\"datetime\"/>\n</person>")
        end
      end
    end
  end
end