require 'spec_helper'

describe Pump::Xml::Value do
  subject { Pump::Xml::Value.new("method_name") }

  describe ".new" do
    it "requires one parameter" do
      expect{ Pump::Xml::Value.new }.to raise_error(ArgumentError)
      expect{ subject }.not_to raise_error
    end
  end

  describe "#plain" do
    its(:plain) { should eql("object.method_name") }
  end

  describe "#to_s" do
    its(:to_s) { should eql("\#{remove_ilegal_chars object.method_name.to_s.encode(:xml => :text)}") }

    context "with option :xmlsafe => true" do
      subject { Pump::Xml::Value.new("method_name", {}, [], :xmlsafe => true) }

      its(:to_s) { should eql("\#{object.method_name}") }
    end

    context "with option :typecast => :xmlschema" do
      subject { Pump::Xml::Value.new("method_name", {}, [], :typecast => :xmlschema) }

      its(:to_s) { should eql("\#{object.method_name.xmlschema}") }
    end

    context "with path name" do
      it do
        expect(subject.to_s('custom_path')).to eql("\#{remove_ilegal_chars custom_path.to_s.encode(:xml => :text)}")
      end
    end
  end
end