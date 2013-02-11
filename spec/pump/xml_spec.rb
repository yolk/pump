require 'spec_helper'

describe Pump::Xml do
  describe ".new" do
    it "requires two parameters" do
      lambda{ Pump::Xml.new }.should raise_error(ArgumentError)
      lambda{ Pump::Xml.new('record') }.should raise_error(ArgumentError)
      lambda{ Pump::Xml.new('record', []) }.should_not raise_error
    end
  end

  describe "#encode" do
    let(:person) { Struct.new(:name, :age, :last_name).new('Benny', 9, 'Hellman') }
    let(:xml) { Pump::Xml.new('person', [{:name => :name}]) }

    it "requires one object" do
      lambda{ xml.encode }.should raise_error(ArgumentError)
      lambda{ xml.encode(person) }.should_not raise_error
    end

    it "returns xml string" do
      xml.encode(person).should eql("#{XML_INSTRUCT}<person>\n  <name>Benny</name>\n</person>\n")
    end

    context "with array" do

      context "with one entry" do
        let(:people) { [person] }

        it "returns xml string" do
          xml.encode(people).should eql("#{XML_INSTRUCT}<people type=\"array\">\n  <person>\n    <name>Benny</name>\n  </person>\n</people>\n")
        end
      end

      context "with multiple entries" do
        let(:people) { [person, Struct.new(:name, :age).new('Carlo', 5)] }

        it "returns xml string" do
          xml.encode(people).should eql("#{XML_INSTRUCT}<people type=\"array\">\n  <person>\n    <name>Benny</name>\n  </person>\n  <person>\n    <name>Carlo</name>\n  </person>\n</people>\n")
        end
      end

      context "with empty array" do
        let(:people) { [] }

        it "returns xml string" do
          xml.encode(people).should eql("#{XML_INSTRUCT}<people type=\"array\"/>\n")
        end
      end

      context "with no instruct" do
        let(:xml) { Pump::Xml.new('person', [{:name => :name}], :instruct => false) }
        let(:people) { [] }

        it "returns xml string" do
          xml.encode(people).should eql("<people type=\"array\"/>\n")
        end
      end

      context "with extra_indent" do
        let(:people) { [person] }
        let(:xml) { Pump::Xml.new('person', [{:name => :name}], :instruct => false, :extra_indent => 1) }

        it "returns xml string" do
          xml.encode(people).should eql("  <people type=\"array\">\n    <person>\n      <name>Benny</name>\n    </person>\n  </people>\n")
        end
      end

      context "with array_root" do
        let(:people) { [person] }
        let(:xml) { Pump::Xml.new('person', [{:name => :name}], :instruct => false, :array_root => "personas") }

        it "returns xml string" do
          xml.encode(people).should eql("<personas type=\"array\">\n  <person>\n    <name>Benny</name>\n  </person>\n</personas>\n")
        end
      end
    end

    context "with no instruct" do
      let(:xml) { Pump::Xml.new('person', [{:name => :name}], :instruct => false) }

      it "returns xml string" do
        xml.encode(person).should eql("<person>\n  <name>Benny</name>\n</person>\n")
      end
    end

    context "with extra_indent" do
      let(:xml) { Pump::Xml.new('person', [{:name => :name}], :instruct => false, :extra_indent => 1) }

      it "returns xml string" do
        xml.encode(person).should eql("  <person>\n    <name>Benny</name>\n  </person>\n")
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
        xml.encode(person).should eql("#{XML_INSTRUCT}<person>\n  <name>Benny</name>\n  <age type=\"integer\">9</age>\n</person>\n")
      end
    end

    context "with blank name" do
      let(:person) { Struct.new(:name, :age).new('', 9) }

      it do
        xml.encode(person).should eql("#{XML_INSTRUCT}<person>\n  <name/>\n</person>\n")
      end
    end

    context "with nil name" do
      let(:person) { Struct.new(:name, :age).new(nil, 9) }

      it do
        xml.encode(person).should eql("#{XML_INSTRUCT}<person>\n  <name/>\n</person>\n")
      end

      context "and with :nil_check => true" do
        let(:xml) { Pump::Xml.new('person', [{:name => :name, :nil_check => true}]) }

        it do
          xml.encode(person).should eql("#{XML_INSTRUCT}<person>\n  <name nil=\"true\"/>\n</person>\n")
        end
      end
    end

    context "with multiple attrubutes" do
      let(:xml) { Pump::Xml.new('person', [{:name => :name}, {:age => :age}]) }

      it "returns xml string" do
        xml.encode(person).should eql("#{XML_INSTRUCT}<person>\n  <name>Benny</name>\n  <age>9</age>\n</person>\n")
      end
    end

    context "with renamed attrubutes" do
      let(:xml) { Pump::Xml.new('person', [{"last-name" => :last_name}]) }

      it "returns xml string" do
        xml.encode(person).should eql("#{XML_INSTRUCT}<person>\n  <last-name>Hellman</last-name>\n</person>\n")
      end
    end

    context "with date attribute" do
      let(:person) { Struct.new(:at).new(Date.new(2013, 2, 7)) }
      let(:xml) { Pump::Xml.new('person', [{:at => :at, :attributes => {:type => 'date'}}]) }

      it "returns xml string" do
        xml.encode(person).should eql("#{XML_INSTRUCT}<person>\n  <at type=\"date\">2013-02-07</at>\n</person>\n")
      end
    end

    context "with datetime attribute" do
      let(:person) { Struct.new(:at).new(Time.new(2013, 2, 7, 0, 0, 0)) }
      let(:xml) { Pump::Xml.new('person', [{:at => :at, :typecast => :xmlschema, :attributes => {:type => 'datetime'}}]) }

      it "returns xml string" do
        xml.encode(person).should eql("#{XML_INSTRUCT}<person>\n  <at type=\"datetime\">2013-02-07T00:00:00+01:00</at>\n</person>\n")
      end

      context "but nil" do
        let(:person) { Struct.new(:at).new(nil) }

        it "returns xml string" do
          xml.encode(person).should eql("#{XML_INSTRUCT}<person>\n  <at type=\"datetime\"/>\n</person>\n")
        end
      end
    end

    context "with conditionals" do
      let(:person) { Struct.new(:name, :age, :is_young, :is_old).new('Gorbatschow', 82, false, true) }

      context "simple if" do
        let(:xml) { Pump::Xml.new('person', [{:name => :name}, {:age => :age, :if => :is_young}]) }

        it "skips tag on false" do
          xml.encode(person).should eql("#{XML_INSTRUCT}<person>\n  <name>Gorbatschow</name>\n</person>\n")
        end
      end

      context "simple unless" do
        let(:xml) { Pump::Xml.new('person', [{:name => :name}, {:age => :age, :unless => :is_old}]) }

        it "skips tag on false" do
          xml.encode(person).should eql("#{XML_INSTRUCT}<person>\n  <name>Gorbatschow</name>\n</person>\n")
        end
      end

      context "chained" do
        let(:xml) { Pump::Xml.new('person', [{:name => :name}, {:age => :age, :unless => 'age.nil?'}]) }
        let(:people) { [person, Struct.new(:name, :age).new('Schewardnadse', nil)] }

        it "skips tag on false" do
          xml.encode(people).should eql("#{XML_INSTRUCT}<people type=\"array\">\n  <person>\n    <name>Gorbatschow</name>\n    <age>82</age>\n  </person>\n  <person>\n    <name>Schewardnadse</name>\n  </person>\n</people>\n")
        end
      end
    end

    context "deep hash-like nesting" do
      let(:xml) { Pump::Xml.new('person', [{:name => :name}, {:parent => [{:name => :name}, {:age => :age}]}], :instruct => false) }

      it "returns xml string" do
        xml.encode(person).should eql("<person>\n  <name>Benny</name>\n  <parent>\n    <name>Benny</name>\n    <age>9</age>\n  </parent>\n</person>\n")
      end
    end

    context "deep array-like nesting" do
      let(:person) { Struct.new(:name, :children).new('Gustav', [Struct.new(:name).new('Lilly'), Struct.new(:name).new('Lena')]) }
      let(:xml) { Pump::Xml.new('person', [{:name => :name}, {:child => :children, :array => [{:name => :name}]}], :instruct => false) }

      it "returns xml string" do
        xml.encode(person).should eql("<person>\n  <name>Gustav</name>\n  <children type=\"array\">\n    <child>\n      <name>Lilly</name>\n    </child>\n    <child>\n      <name>Lena</name>\n    </child>\n  </children>\n</person>\n")
      end
    end



  end
end