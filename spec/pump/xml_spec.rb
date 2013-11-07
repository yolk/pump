require 'spec_helper'

describe Pump::Xml do
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
        xml.encode(person).should eql("#{XML_INSTRUCT}<person>\n  <name></name>\n</person>\n")
      end
    end

    context "with nil name" do
      let(:person) { Struct.new(:name, :age).new(nil, 9) }

      it do
        xml.encode(person).should eql("#{XML_INSTRUCT}<person>\n  <name nil=\"true\"/>\n</person>\n")
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
      let(:person) { Struct.new(:at).new(Time.utc(2013, 2, 7, 0, 0, 0)) }
      let(:xml) { Pump::Xml.new('person', [{:at => :at, :typecast => :xmlschema, :attributes => {:type => 'datetime'}}]) }

      it "returns xml string" do
        xml.encode(person).should eql("#{XML_INSTRUCT}<person>\n  <at type=\"datetime\">2013-02-07T00:00:00Z</at>\n</person>\n")
      end

      context "but nil" do
        let(:person) { Struct.new(:at).new(nil) }

        it "returns xml string" do
          xml.encode(person).should eql("#{XML_INSTRUCT}<person>\n  <at type=\"datetime\" nil=\"true\"/>\n</person>\n")
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

    context "with static_value set" do
      let(:person) { Struct.new(:name, :age, :is_yount).new('Gorbatschow', 82, false) }

      context "replace with other value" do
        let(:xml) { Pump::Xml.new('person', [{:name => :name}, {:age => :age, :static_value => 12}]) }

        it "returns given static_value" do
          xml.encode(person).should eql("#{XML_INSTRUCT}<person>\n  <name>Gorbatschow</name>\n  <age>12</age>\n</person>\n")
        end
      end

      context "replace with nil value" do
        let(:xml) { Pump::Xml.new('person', [{:name => :name}, {:age => :age, :static_value => nil}]) }

        it "returns given static_value" do
          xml.encode(person).should eql("#{XML_INSTRUCT}<person>\n  <name>Gorbatschow</name>\n  <age nil=\"true\"/>\n</person>\n")
        end
      end

      context "replace with other value but with failed condition" do
        let(:xml) { Pump::Xml.new('person', [{:name => :name}, {:age => :age, :static_value => 12, :if => :is_yount}]) }

        it "returns given static_value" do
          xml.encode(person).should eql("#{XML_INSTRUCT}<person>\n  <name>Gorbatschow</name>\n</person>\n")
        end
      end

      context "replace with other value but with succssful condition" do
        let(:xml) { Pump::Xml.new('person', [{:name => :name}, {:age => :age, :static_value => 12, :unless => :is_yount}]) }

        it "returns given static_value" do
          xml.encode(person).should eql("#{XML_INSTRUCT}<person>\n  <name>Gorbatschow</name>\n  <age>12</age>\n</person>\n")
        end
      end
    end

    context "deep hash-like nesting" do
      let(:xml) { Pump::Xml.new('person', [{:name => :name}, {:parent => [{:name => :name}, {:age => :age}]}], :instruct => false) }

      it "returns xml string" do
        xml.encode(person).should eql("<person>\n  <name>Benny</name>\n  <parent>\n    <name>Benny</name>\n    <age>9</age>\n  </parent>\n</person>\n")
      end

      context "with static_value = nil" do
        let(:xml) { Pump::Xml.new('person', [{:name => :name}, {:parent => [{:name => :name}, {:age => :age}], :static_value => nil}], :instruct => false) }

        it "uses static value" do
          xml.encode(person).should eql("<person>\n  <name>Benny</name>\n  <parent nil=\"true\"/>\n</person>\n")
        end
      end

      context "with static_value = ''" do
        let(:xml) { Pump::Xml.new('person', [{:name => :name}, {:parent => [{:name => :name}, {:age => :age}], :static_value => ""}], :instruct => false) }

        it "uses static value" do
          xml.encode(person).should eql("<person>\n  <name>Benny</name>\n  <parent></parent>\n</person>\n")
        end
      end
    end

    context "deep array-like nesting" do
      let(:person) {
        Struct.new(:name, :children).new('Gustav', [
          Struct.new(:name).new('Lilly'),
          Struct.new(:name).new('Lena')
      ]) }

      let(:xml) { Pump::Xml.new('person', [{:name => :name}, {:children => :children,
                                            :array => [{:name => :name}]}], :instruct => false) }

      it "returns xml string" do
        xml.encode(person).should eql("<person>\n  <name>Gustav</name>\n  <children type=\"array\">\n    <child>\n      <name>Lilly</name>\n    </child>\n    <child>\n      <name>Lena</name>\n    </child>\n  </children>\n</person>\n")
      end

      context "overwriting child name" do
        let(:xml) { Pump::Xml.new('person', [{:name => :name}, {:children => :children,
                                            :array => [{:name => :name}], :child_root => 'kid'}], :instruct => false) }

        it "returns xml string" do
          xml.encode(person).should eql("<person>\n  <name>Gustav</name>\n  <children type=\"array\">\n    <kid>\n      <name>Lilly</name>\n    </kid>\n    <kid>\n      <name>Lena</name>\n    </kid>\n  </children>\n</person>\n")
        end
      end

      context "with static_value = nil" do
        let(:xml) { Pump::Xml.new('person', [{:name => :name}, {:children => :children,
                                            :array => [{:name => :name}], :static_value => nil}], :instruct => false) }
        it "uses static value" do
          xml.encode(person).should eql("<person>\n  <name>Gustav</name>\n  <children type=\"array\"/>\n</person>\n")
        end
      end

      context "with static_value = ''" do
        let(:xml) { Pump::Xml.new('person', [{:name => :name}, {:children => :children,
                                            :array => [{:name => :name}], :static_value => ''}], :instruct => false) }
        it "uses static value" do
          xml.encode(person).should eql("<person>\n  <name>Gustav</name>\n  <children type=\"array\"></children>\n</person>\n")
        end
      end
    end

    context "with :xml_key_style option" do
      context "not set" do
        let(:xml) { Pump::Xml.new('my_person', [{"first_name" => :name}]) }

        it "returns xml string with dashes" do
          xml.encode(person).should eql("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<my-person>\n  <first-name>Benny</first-name>\n</my-person>\n")
        end
      end

      context "set to :dashes" do
        let(:xml) { Pump::Xml.new('my_person', [{"first-name" => :name}], :xml_key_style => :dashes) }

        it "returns xml string with dashes" do
          xml.encode(person).should eql("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<my-person>\n  <first-name>Benny</first-name>\n</my-person>\n")
        end
      end

      context "set to :underscores" do
        let(:xml) { Pump::Xml.new('my_person', [{"first-name" => :name}], :xml_key_style => :underscores) }

        it "returns xml string with underscores" do
          xml.encode(person).should eql("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<my_person>\n  <first_name>Benny</first_name>\n</my_person>\n")
        end

        context "on complex array like" do
          let(:person) {
            Struct.new(:name, :children).new('Gustav', [
              Struct.new(:name).new('Lilly'),
              Struct.new(:name).new('Lena')
          ]) }

          let(:xml) { Pump::Xml.new('my-person', [{:"my-name" => :name}, {:"the-children" => :children,
                                                :array => [{:"child-name" => :name}]}], :xml_key_style => :underscores) }

          it "returns xml string with underscores" do
            xml.encode(person).should eql("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<my_person>\n  <my_name>Gustav</my_name>\n  <the_children type=\"array\">\n    <the_child>\n      <child_name>Lilly</child_name>\n    </the_child>\n    <the_child>\n      <child_name>Lena</child_name>\n    </the_child>\n  </the_children>\n</my_person>\n")
          end
        end

        context "on complex array like" do
          let(:xml) { Pump::Xml.new('a-person', [{:"my-name" => :name}, {:"the-parent" => [{:"a-name" => :name}, {:"la-age" => :age}]}], :xml_key_style => :underscores) }

          it "returns xml string with underscores" do
            xml.encode(person).should eql("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<a_person>\n  <my_name>Benny</my_name>\n  <the_parent>\n    <a_name>Benny</a_name>\n    <la_age>9</la_age>\n  </the_parent>\n</a_person>\n")
          end
        end
      end
    end

    context "with :fields option" do
      let(:xml) { Pump::Xml.new('person', [
        {:name => :name}, {:age => :age}, {:last_name => :last_name},
        {:parent => [{:name => :name}, {:age => :age}]}
      ])}

      it "returns only specified fields" do
        xml.encode(person, :fields => ['name']).should eql("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<person>\n  <name>Benny</name>\n</person>\n")
        xml.encode(person, :fields => ['age']).should eql("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<person>\n  <age>9</age>\n</person>\n")
      end

      it "ignores unknown fields" do
        xml.encode(person, :fields => ['name', 'unknown']).should eql("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<person>\n  <name>Benny</name>\n</person>\n")
        xml.encode(person, :fields => ['unknown']).should eql("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<person>\n</person>\n")
      end

      it "accepts dasherized and underscored field names" do
        xml.encode(person, :fields => ['name', 'last-name']).should eql("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<person>\n  <name>Benny</name>\n  <last-name>Hellman</last-name>\n</person>\n")
        xml.encode(person, :fields => ['name', 'last_name']).should eql("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<person>\n  <name>Benny</name>\n  <last-name>Hellman</last-name>\n</person>\n")
      end

      context "deep hash-like nesting" do
        it "adds all keys if fields contains parent" do
          xml.encode(person, :fields => ['name', 'parent']).should eql(
            "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<person>\n  <name>Benny</name>\n  <parent>\n    <name>Benny</name>\n    <age>9</age>\n  </parent>\n</person>\n"
          )
        end
      end

      context "deep array-like nesting" do
        let(:person) {
          Struct.new(:name, :age, :children).new('Gustav', 1, [
            Struct.new(:name, :age).new('Lilly', 2),
            Struct.new(:name, :age).new('Lena', 3)
        ]) }

        let(:xml) { Pump::Xml.new('person', [{:name => :name}, {:age => :age}, {:children => :children,
                                              :array => [{:name => :name}, {:age => :age}]}]) }

        it "adds all keys if fields contains children" do
          xml.encode(person, :fields => ['name', 'children']).should eql(
            "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<person>\n  <name>Gustav</name>\n  <children type=\"array\">\n    <child>\n      <name>Lilly</name>\n      <age>2</age>\n    </child>\n    <child>\n      <name>Lena</name>\n      <age>3</age>\n    </child>\n  </children>\n</person>\n"
          )
        end
      end
    end
  end
end