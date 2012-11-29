require 'spec_helper'

describe Pump::Xml::Tag do
  describe ".new" do
    it "requires one parameter" do
      lambda{ Pump::Xml::Tag.new }.should raise_error(ArgumentError)
      lambda{ Pump::Xml::Tag.new(0) }.should_not raise_error
    end
  end

  describe ".to_s" do
    context "with value node(s)" do
      let(:attributes) { {} }
      let(:options) { {} }
      subject{ Pump::Xml::Tag.new("tag", attributes, Pump::Xml::Value.new('method'), options).to_s }

      it {should eql(
        "<tag\#{v = object.method;''}\#{v.nil? || v == '' ? \"/>\" : \">\#{v.to_s.encode(:xml => :text)}</tag>\"}"
      )}

      context "with :nil_check => true" do
        let(:options) { {:nil_check => true} }

        it {should eql(
          "<tag\#{v = object.method;''}\#{\" nil=\\\"true\\\"\" if v.nil?}\#{v.nil? || v == '' ? \"/>\" : \">\#{v.to_s.encode(:xml => :text)}</tag>\"}"
        )}
      end

      context "with :never_blank => true" do
        let(:options) { {:never_blank => true} }

        it {should eql(
          "<tag>\#{object.method.to_s.encode(:xml => :text)}</tag>"
        )}

        context "with attributes" do
          let(:attributes) { {:foo => "bar"} }

          it {should eql(
            "<tag foo=\\\"bar\\\">\#{object.method.to_s.encode(:xml => :text)}</tag>"
          )}
        end
      end

      context "with :skip_encoding => true" do
        let(:options) { {:skip_encoding => true} }

        it {should eql(
          "<tag\#{v = object.method;''}\#{v.nil? || v == '' ? \"/>\" : \">\#{v}</tag>\"}"
        )}
      end

      context "with attributes" do
        let(:attributes) { {:foo => "bar"} }

        it {should eql(
          "<tag foo=\\\"bar\\\"\#{v = object.method;''}\#{v.nil? || v == '' ? \"/>\" : \">\#{v.to_s.encode(:xml => :text)}</tag>\"}"
        )}
      end
    end

    context "with other tag child nodes" do
      let(:attributes1) { {} }
      let(:options1) { {} }
      let(:attributes2) { {} }
      let(:options2) { {:never_blank => true, :skip_encoding => true} }
      let(:tag2) { Pump::Xml::Tag.new("child", attributes2, Pump::Xml::Value.new('method'), options2) }
      let(:tag1) { Pump::Xml::Tag.new("root", attributes1, [tag2], options1) }
      subject{ tag1.to_s }

      it {should eql(
        "<root>\n  <child>\#{object.method}</child>\n</root>"
      )}
    end
  end
end