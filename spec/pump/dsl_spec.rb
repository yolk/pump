require 'spec_helper'

describe Pump::Dsl do
  subject { Pump::Dsl.new {} }

  describe ".new" do
    it "requires one block" do
      lambda{ Pump::Dsl.new }.should raise_error(ArgumentError)
      lambda{ subject }.should_not raise_error
    end
  end

  describe "#config" do
    its(:config) { should eql([]) }

    context "with tag" do
      subject { Pump::Dsl.new { tag :name } }
      its(:config) { should eql([{:name => :name}]) }

      context "with attributes and options" do
        subject { Pump::Dsl.new { tag :name, :attributes => {:a => 'b'}, :options => false } }
        its(:config) { should eql([{:name => :name, :attributes => {:a => 'b'}, :options => false}]) }
      end

      context "with :from option" do
        subject { Pump::Dsl.new { tag :name, :from => :method_name } }
        its(:config) { should eql([{:name => :method_name}]) }
      end

      context "with dashs in tag name" do
        subject { Pump::Dsl.new { tag :"first-name" } }
        its(:config) { should eql([{:"first-name" => :first_name}]) }
      end
    end

    context "with string" do
      subject { Pump::Dsl.new { string :name } }
      its(:config) { should eql([{:name => :name}]) }

      context "with attributes and options" do
        subject { Pump::Dsl.new { string :name, :attributes => {:a => 'b'}, :options => false } }
        its(:config) { should eql([{:name => :name, :attributes => {:a => 'b'}, :options => false}]) }
      end
    end

    context "with integer" do
      subject { Pump::Dsl.new { integer :name } }
      its(:config) { should eql([{:name => :name, :attributes => {:type => 'integer'}, :xmlsafe => true}]) }

      context "with attributes and options" do
        subject { Pump::Dsl.new { integer :name, :attributes => {:a => 'b'}, :options => false } }
        its(:config) { should eql([{:name => :name, :attributes => {:type => 'integer', :a => 'b'}, :options => false, :xmlsafe => true}]) }
      end
    end

    context "with float" do
      subject { Pump::Dsl.new { float :name } }
      its(:config) { should eql([{:name => :name, :attributes => {:type => 'float'}, :xmlsafe => true}]) }

      context "with attributes and options" do
        subject { Pump::Dsl.new { float :name, :attributes => {:a => 'b'}, :options => false } }
        its(:config) { should eql([{:name => :name, :attributes => {:type => 'float', :a => 'b'}, :options => false, :xmlsafe => true}]) }
      end
    end

    context "with boolean" do
      subject { Pump::Dsl.new { boolean :name } }
      its(:config) { should eql([{:name => :name, :attributes => {:type => 'boolean'}, :xmlsafe => true}]) }

      context "with attributes and options" do
        subject { Pump::Dsl.new { boolean :name, :attributes => {:a => 'b'}, :options => false } }
        its(:config) { should eql([{:name => :name, :attributes => {:type => 'boolean', :a => 'b'}, :options => false, :xmlsafe => true}]) }
      end
    end

    context "with date" do
      subject { Pump::Dsl.new { date :at } }
      its(:config) { should eql([{:at => :at, :attributes => {:type => 'date'}, :xmlsafe => true}]) }

      context "with attributes and options" do
        subject { Pump::Dsl.new { date :at, :attributes => {:a => 'b'}, :options => false } }
        its(:config) { should eql([{:at => :at, :attributes => {:type => 'date', :a => 'b'}, :options => false, :xmlsafe => true}]) }
      end
    end

    context "with (date)time" do
      subject { Pump::Dsl.new { time :at } }
      its(:config) { should eql([{:at => :at, :typecast => :xmlschema, :attributes => {:type => 'datetime'}, :xmlsafe => true}]) }

      context "with attributes and options" do
        subject { Pump::Dsl.new { time :at, :attributes => {:a => 'b'}, :options => false } }
        its(:config) { should eql([{:at => :at, :attributes => {:a => 'b', :type => 'datetime'}, :options => false, :typecast => :xmlschema, :xmlsafe => true}]) }
      end
    end

    context "with nested tags" do
      subject do
        Pump::Dsl.new do
          tag :person, :option => 'x' do
            string :name
            integer :age
          end
          string :parent_name
        end
      end
      its(:config) { should eql([
        {:person => [
          {:name => :name},
          {:age => :age, :attributes => {:type => 'integer'}, :xmlsafe => true}
        ], :option => 'x'},
        {:parent_name => :parent_name}
      ]) }
    end
  end

  context "with array tag" do
    subject do
      Pump::Dsl.new do
        array(:children) do
          tag :name
        end
      end
    end

    its(:config) { should eql(
      [{:children => :children, :array => [{:name => :name}]}]
    )}

    context "with options" do
      subject do
        Pump::Dsl.new do
          array(:children, :from => :kids, :child_root => :ugly_kid_joe) do
            tag :name
          end
        end
      end

      its(:config) { should eql(
        [{:children => :kids, :array => [{:name => :name}], :child_root => :ugly_kid_joe}]
      )}
    end
  end
end