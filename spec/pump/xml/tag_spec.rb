require 'spec_helper'

describe Pump::Xml::Tag do
  describe ".new" do
    it "requires one parameter" do
      expect{ Pump::Xml::Tag.new }.to raise_error(ArgumentError)
      expect{ Pump::Xml::Tag.new(0) }.not_to raise_error
    end
  end
end