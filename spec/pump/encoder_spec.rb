require 'spec_helper'

describe Pump::Encoder do
  describe ".new" do
    it "requires two parameters or one and a block" do
      lambda{ Pump::Encoder.new }.should raise_error(ArgumentError)
      lambda{ Pump::Encoder.new('record') }.should raise_error(ArgumentError)
      lambda{ Pump::Encoder.new('record', []) }.should_not raise_error
      lambda{ Pump::Encoder.new('record') {} }.should_not raise_error
    end

    describe "with block given" do
      subject do
        Pump::Encoder.new('human', :instruct => false) do
          tag :name
        end
      end

      its(:encoder_config) { should eql([{:name=>:name}])}
    end

    describe "with base given in options" do
      let(:base) { Pump::Encoder.new('person', [{:name => :name}, {:role => :role}], {:option => true}) }

      context "adding other param" do
        subject{ Pump::Encoder.new('person', [{:age => :age}], :base => base) }
        its(:encoder_config) { should eql([{:name => :name}, {:role => :role}, {:age => :age}])}
        its(:encoder_options) { should eql({:option => true}) }
        its(:base) { should eql(base) }

        it "leaves base config untouched" do
          subject
          base.encoder_config.should eql([{:name => :name}, {:role => :role}])
        end
      end

      context "adding other param with block" do
        subject{ Pump::Encoder.new('person', :base => base) { tag :age } }
        its(:encoder_config) { should eql([{:name => :name}, {:role => :role}, {:age => :age}])}

        it "leaves base config untouched" do
          subject
          base.encoder_config.should eql([{:name => :name}, {:role => :role}])
        end
      end

      context "alter exisiting param" do
        subject{ Pump::Encoder.new('person', [{:name => :full_name}], :base => base) }
        its(:encoder_config) { should eql([{:name => :full_name}, {:role => :role}])}

        it "leaves base config untouched" do
          subject
          base.encoder_config.should eql([{:name => :name}, {:role => :role}])
        end
      end

      context "alter exisiting param with block" do
        subject do
          Pump::Encoder.new('person', :base => base) do
            string :last_name
            tag :role, :static_value => nil
          end
        end
        its(:encoder_config) { should eql([{:name => :name}, {:role=>:role, :static_value=>nil}, {:last_name => :last_name}])}

        it "leaves base config untouched" do
          subject
          base.encoder_config.should eql([{:name => :name}, {:role => :role}])
        end
      end

      context "adding an option" do
        context "adding other param" do
          subject{ Pump::Encoder.new('person', [], {:other_option => false, :base => base}) }
          its(:encoder_options) { should eql({:other_option => false, :option => true}) }

          it "leaves base options untouched" do
            subject
            base.encoder_options.should eql({:option => true})
          end
        end
      end

      context "adding and overwriting an option" do
        context "adding other param" do
          subject{ Pump::Encoder.new('person', [], {:option => 47, :other_option => false, :base => base}) }
          its(:encoder_options) { should eql({:other_option => false, :option => 47}) }

          it "leaves base options untouched" do
            subject
            base.encoder_options.should eql({:option => true})
          end
        end
      end
    end
  end
end