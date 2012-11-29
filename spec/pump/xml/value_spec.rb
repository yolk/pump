require 'spec_helper'

describe Pump::Xml::Value do
  subject { Pump::Xml::Value.new("method_name") }

  describe ".new" do
    it "requires one parameter" do
      lambda{ Pump::Xml::Value.new }.should raise_error(ArgumentError)
      lambda{ subject }.should_not raise_error
    end
  end

  describe "#plain" do
    its(:plain) { should eql("object.method_name") }
  end

  describe "#to_s" do
    its(:to_s) { should eql("\#{object.method_name.to_s.encode(:xml => :text)}") }

    context "with option :skip_encoding => true" do
      subject { Pump::Xml::Value.new("method_name", {}, [], :skip_encoding => true) }

      its(:to_s) { should eql("\#{object.method_name}") }
    end

    context "with path name" do
      it do
        subject.to_s('custom_path').should eql("\#{custom_path.to_s.encode(:xml => :text)}")
      end
    end
  end
end