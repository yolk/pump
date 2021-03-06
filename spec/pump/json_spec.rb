require 'spec_helper'

describe Pump::Json do
  describe "#to_structs" do
    let(:person) { Struct.new(:name, :age, :last_name).new('Benny', 9, 'Hellman') }
    let(:json) { Pump::Json.new('person', [{:name => :name}]) }

    it "returns json as structure" do
      expect(json.to_structs(person)).to eql({:person=>{:name=>"Benny"}})
      expect(json.to_structs(person, exclude_root_in_json: true)).to eql({:name=>"Benny"})
    end
  end

  describe "#encode" do
    let(:person) { Struct.new(:name, :age, :last_name).new('Benny', 9, 'Hellman') }
    let(:json) { Pump::Json.new('person', [{:name => :name}]) }

    it "requires one object" do
      expect{ json.encode }.to raise_error(ArgumentError)
      expect{ json.encode(person) }.not_to raise_error
    end

    it "returns json string" do
      expect(json.encode(person)).to eql("{\"person\":{\"name\":\"Benny\"}}")
    end

    context "with time object" do
      let(:person) { Struct.new(:born).new(Time.new(2007,11,1,15,25,0, "+09:00")) }
      let(:json) { Pump::Json.new('person', [{:born => :born}]) }

      it "formats time as iso string" do
        expect(json.encode(person)).to eql("{\"person\":{\"born\":\"2007-11-01T15:25:00+09:00\"}}")
      end
    end

    context "with date object" do
      let(:person) { Struct.new(:born).new(Date.new(2007,11,1)) }
      let(:json) { Pump::Json.new('person', [{:born => :born}]) }

      it "formats time as iso string" do
        expect(json.encode(person)).to eql("{\"person\":{\"born\":\"2007-11-01\"}}")
      end
    end

    context "with datetime object" do
      let(:person) { Struct.new(:born).new(DateTime.new(2007,11,1,15,25,0, "+09:00")) }
      let(:json) { Pump::Json.new('person', [{:born => :born}]) }

      it "formats time as iso string" do
        expect(json.encode(person)).to eql("{\"person\":{\"born\":\"2007-11-01T15:25:00+09:00\"}}")
      end
    end

    context "with array" do

      context "with one entry" do
        let(:people) { [person] }

        it "returns json string" do
          expect(json.encode(people)).to eql("[{\"person\":{\"name\":\"Benny\"}}]")
        end
      end

      context "with multiple entries" do
        let(:people) { [person, Struct.new(:name, :age).new('Carlo', 5)] }

        it "returns xml string" do
          expect(json.encode(people)).to eql("[{\"person\":{\"name\":\"Benny\"}},{\"person\":{\"name\":\"Carlo\"}}]")
        end

        context "with exclude_root_in_json option" do
          it "returns json string without root" do
            expect(json.encode(people, :exclude_root_in_json => true)).to eql("[{\"name\":\"Benny\"},{\"name\":\"Carlo\"}]")
          end
        end
      end

      context "with empty array" do
        let(:people) { [] }

        it "returns xml string" do
          expect(json.encode(people)).to eql("[]")
        end
      end
    end

    context "with blank name" do
      let(:person) { Struct.new(:name, :age).new('', 9) }

      it do
        expect(json.encode(person)).to eql("{\"person\":{\"name\":\"\"}}")
      end
    end

    context "with nil name" do
      let(:person) { Struct.new(:name, :age).new(nil, 9) }

      it do
        expect(json.encode(person)).to eql("{\"person\":{\"name\":null}}")
      end
    end

    context "with conditionals" do
      let(:person) { Struct.new(:name, :age, :is_young, :is_old).new('Gorbatschow', 82, false, true) }

      context "simple if" do
        let(:json) { Pump::Json.new('person', [{:name => :name}, {:age => :age, :if => :is_young}]) }

        it "skips key-value on false" do
          expect(json.encode(person)).to eql("{\"person\":{\"name\":\"Gorbatschow\"}}")
        end
      end

      context "simple unless" do
        let(:json) { Pump::Json.new('person', [{:name => :name}, {:age => :age, :unless => :is_old}]) }

        it "skips key-value on false" do
          expect(json.encode(person)).to eql("{\"person\":{\"name\":\"Gorbatschow\"}}")
        end
      end

      context "chained" do
        let(:json) { Pump::Json.new('person', [{:name => :name}, {:age => :age, :unless => 'age.nil?'}]) }
        let(:people) { [person, Struct.new(:name, :age).new('Schewardnadse', nil)] }

        it "skips key-value on false" do
          expect(json.encode(people)).to eql("[{\"person\":{\"name\":\"Gorbatschow\",\"age\":82}},{\"person\":{\"name\":\"Schewardnadse\"}}]")
        end
      end
    end

    context "with static_value set" do
      let(:person) { Struct.new(:name, :age, :is_yount).new('Gorbatschow', 82, false) }

      context "replace with other value" do
        let(:json) { Pump::Json.new('person', [{:name => :name}, {:age => :age, :static_value => 12}]) }

        it "returns given static_value" do
          expect(json.encode(person)).to eql("{\"person\":{\"name\":\"Gorbatschow\",\"age\":12}}")
        end
      end

      context "replace with nil value" do
        let(:json) { Pump::Json.new('person', [{:name => :name}, {:age => :age, :static_value => nil}]) }

        it "returns given static_value" do
          expect(json.encode(person)).to eql("{\"person\":{\"name\":\"Gorbatschow\",\"age\":null}}")
        end
      end

      context "replace with other value but with failed condition" do
        let(:json) { Pump::Json.new('person', [{:name => :name}, {:age => :age, :static_value => 12, :if => :is_yount}]) }

        it "returns given static_value" do
          expect(json.encode(person)).to eql("{\"person\":{\"name\":\"Gorbatschow\"}}")
        end
      end

      context "replace with other value but with succssful condition" do
        let(:json) { Pump::Json.new('person', [{:name => :name}, {:age => :age, :static_value => 12, :unless => :is_yount}]) }

        it "returns given static_value" do
          expect(json.encode(person)).to eql("{\"person\":{\"name\":\"Gorbatschow\",\"age\":12}}")
        end
      end
    end

    context "deep hash-like nesting" do
      let(:json) { Pump::Json.new('person', [{:name => :name}, {:parent => [{:name => :name}, {:age => :age}]}]) }

      it "returns static string" do
        expect(json.encode(person)).to eql("{\"person\":{\"name\":\"Benny\",\"parent\":{\"name\":\"Benny\",\"age\":9}}}")
      end

      context "with static_value = nil" do
        let(:json) { Pump::Json.new('person', [{:name => :name}, {:parent => [{:name => :name}, {:age => :age}], :static_value => nil}]) }

        it "uses static value" do
          expect(json.encode(person)).to eql("{\"person\":{\"name\":\"Benny\",\"parent\":null}}")
        end
      end

      context "with static_value = {}" do
        let(:json) { Pump::Json.new('person', [{:name => :name}, {:parent => [{:name => :name}, {:age => :age}], :static_value => {}}]) }

        it "uses static value" do
          expect(json.encode(person)).to eql("{\"person\":{\"name\":\"Benny\",\"parent\":{}}}")
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
                                            :array => [{:name => :name}]}]) }

      it "returns json string" do
        expect(json.encode(person)).to eql("{\"person\":{\"name\":\"Gustav\",\"children\":[{\"name\":\"Lilly\"},{\"name\":\"Lena\"}]}}")
      end

      context "with static_value = nil" do
        let(:json) { Pump::Json.new('person', [{:name => :name}, {:children => :children,
                                            :array => [{:name => :name}], :static_value => nil}]) }
        it "uses static value" do
          expect(json.encode(person)).to eql("{\"person\":{\"name\":\"Gustav\",\"children\":[]}}")
        end
      end

      context "with static_value = []" do
        let(:json) { Pump::Json.new('person', [{:name => :name}, {:children => :children,
                                            :array => [{:name => :name}], :static_value => []}]) }
        it "uses static value" do
          expect(json.encode(person)).to eql("{\"person\":{\"name\":\"Gustav\",\"children\":[]}}")
        end
      end
    end

    context "with :json_key_style option" do
      context "not set" do
        let(:json) { Pump::Json.new('my-person', [{"first-name" => :name}]) }

        it "returns json string with underscores" do
          expect(json.encode(person)).to eql("{\"my_person\":{\"first_name\":\"Benny\"}}")
        end
      end

      context "set to :dashes" do
        let(:json) { Pump::Json.new('my-person', [{"first-name" => :name}], :json_key_style => :dashes) }

        it "returns json string with dashes" do
          expect(json.encode(person)).to eql("{\"my-person\":{\"first-name\":\"Benny\"}}")
        end
      end

      context "set to :underscores" do
        let(:json) { Pump::Json.new('my-person', [{"first-name" => :name}], :json_key_style => :underscores) }

        it "returns json string with underscores" do
          expect(json.encode(person)).to eql("{\"my_person\":{\"first_name\":\"Benny\"}}")
        end
      end
    end

    context "with :exclude_root_in_json option" do
      it "returns json string without root" do
        expect(json.encode(person, :exclude_root_in_json => true)).to eql("{\"name\":\"Benny\"}")
      end

      it "returns json string without root on array" do
        expect(json.encode([person], :exclude_root_in_json => true)).to eql("[{\"name\":\"Benny\"}]")
      end
    end

    context "with :fields option" do
      let(:json) { Pump::Json.new('person', [
        {:name => :name}, {:age => :age}, {:last_name => :last_name},
        {:parent => [{:name => :name}, {:age => :age}]}
      ])}

      it "returns only specified fields" do
        expect(json.encode(person, :fields => ['name'])).to eql("{\"person\":{\"name\":\"Benny\"}}")
        expect(json.encode(person, :fields => ['age'])).to eql("{\"person\":{\"age\":9}}")
      end

      it "ignores unknown fields" do
        expect(json.encode(person, :fields => ['name', 'unknown'])).to eql("{\"person\":{\"name\":\"Benny\"}}")
        expect(json.encode(person, :fields => ['unknown'])).to eql("{\"person\":{}}")
      end

      it "accepts dasherized and underscored field names" do
        expect(json.encode(person, :fields => ['name', 'last-name'])).to eql("{\"person\":{\"name\":\"Benny\",\"last_name\":\"Hellman\"}}")
        expect(json.encode(person, :fields => ['name', 'last_name'])).to eql("{\"person\":{\"name\":\"Benny\",\"last_name\":\"Hellman\"}}")
      end

      context "deep hash-like nesting" do
        it "adds all keys if fields contains parent" do
          expect(json.encode(person, :fields => ['name', 'parent'])).to eql(
            "{\"person\":{\"name\":\"Benny\",\"parent\":{\"name\":\"Benny\",\"age\":9}}}"
          )
        end
      end

      context "deep array-like nesting" do
        let(:person) {
          Struct.new(:name, :age, :children).new('Gustav', 1, [
            Struct.new(:name, :age).new('Lilly', 2),
            Struct.new(:name, :age).new('Lena', 3)
        ]) }

        let(:json) { Pump::Json.new('person', [{:name => :name}, {:age => :age}, {:children => :children,
                                              :array => [{:name => :name}, {:age => :age}]}]) }

        it "adds all keys if fields contains children" do
          expect(json.encode(person, :fields => ['name', 'children'])).to eql(
            "{\"person\":{\"name\":\"Gustav\",\"children\":[{\"name\":\"Lilly\",\"age\":2},{\"name\":\"Lena\",\"age\":3}]}}"
          )
        end
      end

      context "with array of objects" do
        let(:people) {
          [
            Struct.new(:name, :age, :children).new('Gustav', 2),
            Struct.new(:name, :age, :children).new('Mary', 1)
          ]
        }

        let(:json) { Pump::Json.new('person', [{:name => :name}, {:age => :age}]) }

        it "returns only specified fields" do
          expect(json.encode(people, :fields => ['name'])).to eql("[{\"person\":{\"name\":\"Gustav\"}},{\"person\":{\"name\":\"Mary\"}}]")
        end
      end
    end
  end
end
