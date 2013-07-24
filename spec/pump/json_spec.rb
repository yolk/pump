require 'spec_helper'

describe Pump::Json do
  describe ".new" do
    it "requires two parameters or one and a block" do
      lambda{ Pump::Json.new }.should raise_error(ArgumentError)
      lambda{ Pump::Json.new('record') }.should raise_error(ArgumentError)
      lambda{ Pump::Json.new('record', []) }.should_not raise_error
      lambda{ Pump::Json.new('record') {} }.should_not raise_error
    end

    describe "with block given" do
      subject do
        Pump::Json.new('human') do
          tag :name
        end.encode(Struct.new(:name).new('Artur'))
      end

      its(:encode) { should eql("{\"human\":{\"name\":\"Artur\"}}")}
    end
  end

  describe "#encode" do
    let(:person) { Struct.new(:name, :age, :last_name).new('Benny', 9, 'Hellman') }
    let(:json) { Pump::Json.new('person', [{:name => :name}]) }

    it "requires one object" do
      lambda{ json.encode }.should raise_error(ArgumentError)
      lambda{ json.encode(person) }.should_not raise_error
    end

    it "returns json string" do
      json.encode(person).should eql("{\"person\":{\"name\":\"Benny\"}}")
    end

    context "with array" do

      context "with one entry" do
        let(:people) { [person] }

        it "returns json string" do
          json.encode(people).should eql("[{\"person\":{\"name\":\"Benny\"}}]")
        end
      end

      context "with multiple entries" do
        let(:people) { [person, Struct.new(:name, :age).new('Carlo', 5)] }

        it "returns xml string" do
          json.encode(people).should eql("[{\"person\":{\"name\":\"Benny\"}},{\"person\":{\"name\":\"Carlo\"}}]")
        end
      end

      context "with empty array" do
        let(:people) { [] }

        it "returns xml string" do
          json.encode(people).should eql("[]")
        end
      end
    end

    context "with blank name" do
      let(:person) { Struct.new(:name, :age).new('', 9) }

      it do
        json.encode(person).should eql("{\"person\":{\"name\":\"\"}}")
      end
    end

    context "with nil name" do
      let(:person) { Struct.new(:name, :age).new(nil, 9) }

      it do
        json.encode(person).should eql("{\"person\":{\"name\":null}}")
      end
    end

    context "with conditionals" do
      let(:person) { Struct.new(:name, :age, :is_young, :is_old).new('Gorbatschow', 82, false, true) }

      context "simple if" do
        let(:json) { Pump::Json.new('person', [{:name => :name}, {:age => :age, :if => :is_young}]) }

        it "skips key-value on false" do
          json.encode(person).should eql("{\"person\":{\"name\":\"Gorbatschow\"}}")
        end
      end

      context "simple unless" do
        let(:json) { Pump::Json.new('person', [{:name => :name}, {:age => :age, :unless => :is_old}]) }

        it "skips key-value on false" do
          json.encode(person).should eql("{\"person\":{\"name\":\"Gorbatschow\"}}")
        end
      end

      context "chained" do
        let(:json) { Pump::Json.new('person', [{:name => :name}, {:age => :age, :unless => 'age.nil?'}]) }
        let(:people) { [person, Struct.new(:name, :age).new('Schewardnadse', nil)] }

        it "skips key-value on false" do
          json.encode(people).should eql("[{\"person\":{\"name\":\"Gorbatschow\",\"age\":82}},{\"person\":{\"name\":\"Schewardnadse\"}}]")
        end
      end
    end

    context "with static_value set" do
      let(:person) { Struct.new(:name, :age, :is_yount).new('Gorbatschow', 82, false) }

      context "replace with other value" do
        let(:json) { Pump::Json.new('person', [{:name => :name}, {:age => :age, :static_value => 12}]) }

        it "returns given static_value" do
          json.encode(person).should eql("{\"person\":{\"name\":\"Gorbatschow\",\"age\":12}}")
        end
      end

      context "replace with nil value" do
        let(:json) { Pump::Json.new('person', [{:name => :name}, {:age => :age, :static_value => nil}]) }

        it "returns given static_value" do
          json.encode(person).should eql("{\"person\":{\"name\":\"Gorbatschow\",\"age\":null}}")
        end
      end

      context "replace with other value but with failed condition" do
        let(:json) { Pump::Json.new('person', [{:name => :name}, {:age => :age, :static_value => 12, :if => :is_yount}]) }

        it "returns given static_value" do
          json.encode(person).should eql("{\"person\":{\"name\":\"Gorbatschow\"}}")
        end
      end

      context "replace with other value but with succssful condition" do
        let(:json) { Pump::Json.new('person', [{:name => :name}, {:age => :age, :static_value => 12, :unless => :is_yount}]) }

        it "returns given static_value" do
          json.encode(person).should eql("{\"person\":{\"name\":\"Gorbatschow\",\"age\":12}}")
        end
      end
    end

    context "deep hash-like nesting" do
      let(:json) { Pump::Json.new('person', [{:name => :name}, {:parent => [{:name => :name}, {:age => :age}]}], :instruct => false) }

      it "returns static string" do
        json.encode(person).should eql("{\"person\":{\"name\":\"Benny\",\"parent\":{\"name\":\"Benny\",\"age\":9}}}")
      end

      context "with static_value = nil" do
        let(:json) { Pump::Json.new('person', [{:name => :name}, {:parent => [{:name => :name}, {:age => :age}], :static_value => nil}], :instruct => false) }

        it "uses static value" do
          json.encode(person).should eql("{\"person\":{\"name\":\"Benny\",\"parent\":null}}")
        end
      end

      context "with static_value = {}" do
        let(:json) { Pump::Json.new('person', [{:name => :name}, {:parent => [{:name => :name}, {:age => :age}], :static_value => {}}], :instruct => false) }

        it "uses static value" do
          json.encode(person).should eql("{\"person\":{\"name\":\"Benny\",\"parent\":{}}}")
        end
      end
    end

    context "deep array-like nesting" do
      let(:person) {
        Struct.new(:name, :children).new('Gustav', [
          Struct.new(:name).new('Lilly'),
          Struct.new(:name).new('Lena')
      ]) }

      let(:json) { Pump::Json.new('person', [{:name => :name}, {:children => :children,
                                            :array => [{:name => :name}]}], :instruct => false) }

      it "returns json string" do
        json.encode(person).should eql("{\"person\":{\"name\":\"Gustav\",\"children\":[{\"name\":\"Lilly\"},{\"name\":\"Lena\"}]}}")
      end

      context "with static_value = nil" do
        let(:json) { Pump::Json.new('person', [{:name => :name}, {:children => :children,
                                            :array => [{:name => :name}], :static_value => nil}], :instruct => false) }
        it "uses static value" do
          json.encode(person).should eql("{\"person\":{\"name\":\"Gustav\",\"children\":[]}}")
        end
      end

      context "with static_value = []" do
        let(:json) { Pump::Json.new('person', [{:name => :name}, {:children => :children,
                                            :array => [{:name => :name}], :static_value => []}], :instruct => false) }
        it "uses static value" do
          json.encode(person).should eql("{\"person\":{\"name\":\"Gustav\",\"children\":[]}}")
        end
      end
    end

    context "with underscore option" do
      context "not set" do
        let(:json) { Pump::Json.new('my-person', [{"first-name" => :name}]) }

        it "returns json string with underscores" do
          json.encode(person).should eql("{\"my_person\":{\"first_name\":\"Benny\"}}")
        end
      end

      context "set to false" do
        let(:json) { Pump::Json.new('my-person', [{"first-name" => :name}], :underscore => false) }

        it "returns json string with dashes" do
          json.encode(person).should eql("{\"my-person\":{\"first-name\":\"Benny\"}}")
        end
      end

      context "set to true" do
        let(:json) { Pump::Json.new('my-person', [{"first-name" => :name}], :underscore => true) }

        it "returns json string with underscores" do
          json.encode(person).should eql("{\"my_person\":{\"first_name\":\"Benny\"}}")
        end
      end
    end
  end
end