require "spec_helper"

describe LuceneQueryParser::Parser do
  let(:parser) { LuceneQueryParser::Parser.new }

  describe "#parse" do
    it "parses a term" do
      should parse("foo").as({:term => "foo"})
    end

    it "parses a phrase" do
      should parse('"foo bar"').as({:phrase => "foo bar"})
    end

    it "parses a term and a phrase" do
      parse(%q(foo "stuff and things")).as [
        {:term => "foo"},
        {:phrase => "stuff and things"}
      ]
    end

    it "parses a phrase and two terms" do
      should parse(%q("foo bar" isn't one)).as [
        {:phrase => "foo bar"},
        {:term => "isn't"},
        {:term => "one"}
      ]
    end

    it "parses multiple phrases" do
      should parse(%q("foo bar"~3 "mumble stuff"~5 "blah blah")).as [
        {:phrase => "foo bar", :distance => "3"},
        {:phrase => "mumble stuff", :distance => "5"},
        {:phrase => "blah blah"}
      ]
    end

    it "parses a nearness query" do
      should parse(%q("foo bar"~2)).as(
        {:phrase => "foo bar", :distance => "2"}
      )
    end

    it "parses a paren grouping" do
      should parse(%q((foo bar))).as(
        {:group => [{:term => "foo"}, {:term => "bar"}]}
      )
    end

    it "parses nested paren groups" do
      should parse(%q((foo (bar (baz))))).as(
        {:group => [
          {:term => "foo"},
          {:group => [
            {:term => "bar"},
            {:group => {:term => "baz"}}
          ]}
        ]}
      )
    end

    it "parses a required term" do
      should parse("+foo").as({:term => "foo", :required => "+"})
    end

    it "parses a prohibited term" do
      should parse("-foo").as({:term => "foo", :prohibited => "-"})
    end

    it "parses prohibited groups and phrases" do
      should parse(%q(+(foo bar) -"mumble stuff")).as [
        {:group => [{:term => "foo"}, {:term => "bar"}], :required => "+"},
        {:phrase => "mumble stuff", :prohibited => "-"}
      ]
    end

    it "ignores leading spaces" do
      should parse("   foo bar").as [{:term => "foo"}, {:term => "bar"}]
    end

    it "ignores trailing spaces" do
      should parse("foo bar   ").as [{:term => "foo"}, {:term => "bar"}]
    end

    it "ignores trailing spaces" do

    end

    it "parses AND groupings" do
      should parse(%q(foo AND bar)).as [
        {:term => "foo"},
        {:op => "AND", :term => "bar"}
      ]
    end

    it "parses a sequence of AND and OR" do
      should parse(%q(foo AND bar OR baz OR mumble)).as [
        {:term => "foo"},
        {:op => "AND", :term => "bar"},
        {:op => "OR", :term => "baz"},
        {:op => "OR", :term => "mumble"}
      ]
    end

    it "parses NOTs" do
      should parse("foo NOT bar").as [
        {:term => "foo"},
        {:term => "bar", :op => "NOT"}
      ]
    end

    it "parses field:value" do
      should parse("title:foo").as(
        {:field => "title", :term => "foo"}
      )
    end

    it 'parses field:"a phrase"' do
      should parse('title:"a phrase"').as(
        {:field => "title", :phrase => "a phrase"}
      )
    end

    it "parses field:(foo AND bar)" do
      should parse('title:(foo AND bar)').as(
        {:field => "title", :group => [
          {:term => "foo"},
          {:op => "AND", :term => "bar"}
        ]}
      )
    end

    it "parses fuzzy terms" do
      should parse('fuzzy~').as(
        {:term => "fuzzy", :fuzzy => "~", :similarity => nil}
      )
    end

    it "parses a fuzzy similarity of 0" do
      should parse('fuzzy~0').as(
        {:term => "fuzzy", :fuzzy => "~", :similarity => "0"}
      )
    end

    it "parses a fuzzy similarity of 1" do
      should parse('fuzzy~1').as(
        {:term => "fuzzy", :fuzzy => "~", :similarity => "1"}
      )
    end

    it "parses a fuzzy similarity of 0.8" do
      should parse('fuzzy~0.8').as(
        {:term => "fuzzy", :fuzzy => "~", :similarity => "0.8"}
      )
    end

    it { should parse('year:[2010 TO 2011]').as(
      {:field => "year", :inclusive_range => {:from => "2010", :to => "2011"}}
    ) }

    it { should parse('year:{2009 TO 2012}').as(
      {:field => "year", :exclusive_range => {:from => "2009", :to => "2012"}}
    ) }

  end

end
