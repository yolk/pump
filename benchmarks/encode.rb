#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'

require 'benchmark'
require 'to_json'
require 'pump'
require 'ox'
require 'oj'
require 'yajl'
require 'active_model'

class Person < Struct.new(:name, :age, :created_at)
  include ActiveModel::Serializers::Xml if defined?(ActiveModel)
  include ActiveModel::Serializers::JSON if defined?(ActiveModel)

  def attributes
    {'name' => name, 'age' => age, 'created_at' => created_at}
  end
end

pump_json = Pump::Json.new('person', [
  {:age => :age, :attributes => {:type => 'integer'}},
  {:"created-at" => :created_at, :typecast => :xmlschema, :attributes => {:type => 'datetime'}, :never_nil => true},
  {:name => :name}
])

module ToJsonBench

  class PeopleSerializer
    include  ::ToJson::Serialize

    def put_person(person)
      put :name, person.name
      put :age, person.age
      put :"created-at", person.created_at.xmlschema
    end

    def put_people(people)
      array people do |person|
        put_person person
      end
    end

    def serialize(collection)
      put_people collection
    end
  end
end

# Not optimized pump
pump = Pump::Xml.new('person', [
  {:age => :age, :attributes => {:type => 'integer'}},
  {:"created-at" => :created_at, :typecast => :xmlschema, :attributes => {:type => 'datetime'}, :never_nil => true},
  {:name => :name}
])

# Heavily optimized pump
pump_optimized = Pump::Xml.new('person', [
  {:age => :age, :attributes => {:type => 'integer'}, :never_nil => true, :xmlsafe => true},
  {:"created-at" => :created_at, :typecast => :xmlschema, :attributes => {:type => 'datetime'}, :never_nil => true, :xmlsafe => true},
  {:name => :name, :never_nil => true}
])

if defined?(Ox)
  def serialize_with_ox(people)
    doc = Ox::Document.new(:version => '1.0', :encoding => 'UTF-8')
    root = Ox::Element.new('people')
    root[:type] = "array"
    people.each{|person| serialize_single_with_ox(person, root) }
    doc << root
    Ox.dump(doc, :with_xml => true)
  end

  def serialize_single_with_ox(person, base_root=nil)
    root = Ox::Element.new('person')

    created_at = Ox::Element.new('created-at')
    created_at[:type] = "datetime"
    created_at << person.created_at.xmlschema
    root << created_at

    age = Ox::Element.new('age')
    age[:type] = "integer"
    age << person.age.inspect
    root << age

    name = Ox::Element.new('name')
    name << person.name
    root << name

    unless base_root
      doc = Ox::Document.new(:version => '1.0', :encoding => 'UTF-8')
      doc << root
      Ox.dump(doc, :with_xml => true)
    else
      base_root << root
    end
  end
end

# Lets generate some random persons
array = []
100.times do
  array << Person.new((0...(rand(15)+5)).map{ ('a'..'z').to_a[rand(26)] }.join, rand(100), Time.now + rand(1000000))
end

times = ARGV[1] ? ARGV[1].to_i : 1000
puts "Starting benchmark serializing array with #{array.size} entries #{times} times\n\n"

Benchmark.bmbm { |x|

  x.report("Pump::Json#encode") {
    times.times {
      pump_json.encode(array)
    }
  }

  x.report("ToJson") {
    times.times {
      ToJsonBench::PeopleSerializer.json!(array)
    }
  }

  x.report("Pump::Xml#encode") {
    times.times {
      pump.encode(array)
    }
  }

  x.report("Pump::Xml#encode (optimized)") {
    times.times {
      pump_optimized.encode(array)
    }
  }

  if defined?(Ox)
    x.report("Ox") {
      times.times {
        serialize_with_ox(array)
      }
    }
  end

  if defined?(Oj)
    x.report("Oj") {
      times.times {
        Oj.dump(array.map(&:attributes), :mode => :compat)
      }
    }
  end

  if defined?(Yajl)
    x.report("Yajl") {
      times.times {
        Yajl::Encoder.encode(array.map(&:attributes))
      }
    }
  end

  if defined?(ActiveModel)
    x.report("ActiveModel#to_xml") {
      times.times {
        array.to_xml
      }
    }

    x.report("ActiveModel#to_json") {
      times.times {
        array.to_json
      }
    }
  end
}
