require 'spec_helper'

describe Pump::Xml::TagArray do
  describe ".new" do
    it "requires one parameter" do
      expect{ Pump::Xml::TagArray.new }.to raise_error(ArgumentError)
      expect{ Pump::Xml::TagArray.new('tag') }.not_to raise_error
    end
  end
end