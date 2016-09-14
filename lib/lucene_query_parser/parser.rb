module LuceneQueryParser
  class Parser < Parslet::Parser

    # Public: find and explain errors in a query, if any
    #
    # query - the query to check
    #
    # Returns nil if the query is parseable, or a hash containing information
    # about the invalid query if not.
    def error_location(query)
      parse query
      nil
    rescue Parslet::ParseFailed => error
      cause = error.cause.ascii_tree
      cause =~ /line (\d+) char (\d+)/
      {:line => $1.to_i, :column => $2.to_i, :message => cause}
    end

    # Public: constructor takes optional named pairs,
    # including:
    #
    #   :term_re => string    # regex string for matching term
    #
    def initialize(args={})
      if args[:term_re]
        @term_re = args[:term_re]
        term_re_str = @term_re.to_s  # in case passed as actual Regexp

        # must define :term rule at run-time so that it can include
        # the term_re_str
        self.class.rule :term do
          ( (escape_special_words | match[term_re_str]).repeat(1) ).as(:term) >> (fuzzy | boost).maybe
        end
      else
        self.class.rule :term do
          ( (escape_special_words | match["\\w\\'\\.\\*\\?\\-"]).repeat(1) ).as(:term) >> (fuzzy | boost).maybe
        end
      end
    end

    # ----- grammar definition -----

    root :expr

    rule :expr do
      space.maybe >>
      operand >> (space.maybe >> (operator >> space.maybe >> operand | operand)).repeat >>
      space.maybe
    end

    rule :operator do
      str('AND').as(:op) | str('OR').as(:op) | str('&&').as(:op) | str('||').as(:op)
    end

    rule :operand do
      unary_operator.maybe >> space.maybe >> (
        group |
        field |
        term |
        phrase
      )
    end

    rule :escape_special_words do
      (str('\\') >> match['^\\w']).repeat(1)
    end

    rule :phrase do
      str('"') >> match['^"'].repeat(1).as(:phrase) >> str('"') >>
      (distance | boost).maybe
    end

    rule :group do
      str('(') >> space.maybe >> expr.as(:group) >> space.maybe >> str(')') >>
      boost.maybe
    end

    rule :field do
      match["\\w\\."].repeat(1).as(:field) >> str(':') >>
      (
        term | phrase | group |
        inclusive_range.as(:inclusive_range) |
        exclusive_range.as(:exclusive_range)
      )
    end

    rule :inclusive_range do
      str('[') >> space.maybe >>
      (range_word | range_wildcard).as(:from) >> space >> str('TO') >> space >>
      (range_word | range_wildcard).as(:to) >> space.maybe >> str(']')
    end

    rule :exclusive_range do
      str('{') >> space.maybe >>
      (range_word | range_wildcard).as(:from) >> space >> str('TO') >> space >>
      (range_word | range_wildcard).as(:to) >> space.maybe >> str('}')
    end

    rule :unary_operator do
      str('+').as(:required) |
      str('-').as(:prohibited) |
      str('!').as(:prohibited) |
      (str('NOT').as(:op) >> space)
    end

    rule :distance do
      space.maybe >> str('~') >> space.maybe >> match['0-9'].repeat(1).as(:distance)
    end

    rule :fuzzy do
      space.maybe >> str('~') >>
      ( str('0.') >> match['0-9'].repeat(1) | match['01'] ).maybe.as(:similarity)
    end

    rule :boost do
      space.maybe >> str('^') >> space.maybe >> (
        str('0.') >> match['0-9'].repeat(1) |
        match['0-9'].repeat(1)
      ).as(:boost)
    end

    rule :range_wildcard do
      match["*"].repeat(1)
    end

    rule :word do
      match["\\w"].repeat(1)
    end

    rule :range_word do
      match["0-9a-z\\-."].repeat(1)
    end

    rule :space do
      match["\n \t\u00a0\u200B"].repeat(1)
    end

  end
end
