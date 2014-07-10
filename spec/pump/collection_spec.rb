require 'spec_helper'

describe Pump::Collection do
  subject { Pump::Collection.new }

  describe ".new" do
    it "should not accept any arguments" do
      subject
      expect{ Pump::Collection.new("") }.to raise_error(ArgumentError)
    end

    its(:size) { should eql(0) }
  end

  describe "#add" do
    it "should add entry" do
      subject.add(:set_name, :xml, :value)
      expect(subject.size).to eql(1)
    end

    it "should allow different formats" do
      subject.add(:set_name, :json, :value)
      expect(subject.size).to eql(1)
    end

    it "should default to :default set" do
      subject.add(nil, :xml, :value)
      expect(subject.get(:default, :xml)).to eql(:value)
    end
  end

  describe "#get" do
    it "should return nil on unknown entry" do
      expect(subject.get(:set_name, :xml)).to eql(nil)
      expect(subject.get(:default, :xml)).to eql(nil)
      expect(subject.get(nil, :xml)).to eql(nil)
      expect(subject.get(:default, :json)).to eql(nil)
    end

    context "when entries are added" do
      before{ subject.add(:set_name, :xml, :value); subject.add(:default, :xml, :value2) }

      it "should return given value" do
        expect(subject.get(:set_name, :xml)).to eql(:value)
        expect(subject.get(:default, :xml)).to eql(:value2)
      end

      it "should return nil with wrong format" do
        expect(subject.get(:set_name, :json)).to eql(nil)
        expect(subject.get(:default, :json)).to eql(nil)
      end

      it "should default to :default on unknwon set" do
        expect(subject.get(:unknown, :xml)).to eql(:value2)
      end
    end
  end
end