require "spec_helper"

describe LuceneQueryParser::Parser do
  let(:parser) { LuceneQueryParser::Parser.new }

  describe "#parse" do
    it "parses a term" do
      parser.parse("foo").should == {:term => "foo"}
    end
  end
end
