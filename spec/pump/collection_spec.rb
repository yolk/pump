require 'spec_helper'

describe Pump::Collection do
  subject { Pump::Collection.new }

  describe ".new" do
    it "should not accept any arguments" do
      subject
      lambda{ Pump::Collection.new("") }.should raise_error(ArgumentError)
    end

    its(:size) { should eql(0) }
  end

  describe "#add" do
    it "should add entry" do
      subject.add(:set_name, :xml, :value)
      subject.size.should eql(1)
    end

    it "should allow different formats" do
      subject.add(:set_name, :json, :value)
      subject.size.should eql(1)
    end

    it "should default to :default set" do
      subject.add(nil, :xml, :value)
      subject.get(:default, :xml).should eql(:value)
    end
  end

  describe "#get" do
    it "should return nil on unknown entry" do
      subject.get(:set_name, :xml).should eql(nil)
      subject.get(:default, :xml).should eql(nil)
      subject.get(nil, :xml).should eql(nil)
      subject.get(:default, :json).should eql(nil)
    end

    context "when entries are added" do
      before{ subject.add(:set_name, :xml, :value); subject.add(:default, :xml, :value2) }

      it "should return given value" do
        subject.get(:set_name, :xml).should eql(:value)
        subject.get(:default, :xml).should eql(:value2)
      end

      it "should return nil with wrong format" do
        subject.get(:set_name, :json).should eql(nil)
        subject.get(:default, :json).should eql(nil)
      end

      it "should default to :default on unknwon set" do
        subject.get(:unknown, :xml).should eql(:value2)
      end
    end
  end
end