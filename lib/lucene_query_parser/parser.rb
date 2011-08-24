module LuceneQueryParser
  class Parser < Parslet::Parser

    # Public: find and explain the errors in a query
    #
    # query - the query to check
    #
    # Returns nil if the query is parseable, or a hash containing information
    # about the invalid query if not.
    def error_location(query)
      parse query
      nil
    rescue Parslet::ParseFailed => error
      cause = find_cause root.error_tree
      cause =~ /line (\d+) char (\d+)/
      {:line => $1.to_i, :column => $2.to_i, :message => cause}
    end

    def find_cause(node)
      if node.parslet.cause
        node.cause
      else
        node.children.reverse.each do |child|
          if cause = find_cause(child)
            return cause
          end
        end
      end
    end

    root :expr

    rule :expr do
      space.maybe >>
      operand >> (space >> (operator >> space >> operand | operand)).repeat >>
      space.maybe
    end

    rule :operator do
      str('AND').as(:op) | str('OR').as(:op)
    end

    rule :operand do
      unary_operator.maybe >> (
        group |
        field |
        term |
        phrase
      )
    end

    rule :term do
      match["\\w'"].repeat(1).as(:term) >> (fuzzy | boost).maybe
    end

    rule :phrase do
      str('"') >> match['^"'].repeat(1).as(:phrase) >> str('"') >>
      (distance | boost).maybe
    end

    rule :distance do
      str('~') >> match['0-9'].repeat(1).as(:distance)
    end

    rule :group do
      str('(') >> space.maybe >> expr.as(:group) >> space.maybe >> str(')')
    end

    rule :field do
      match["\\w"].repeat(1).as(:field) >> str(':') >>
      (
        term | phrase | group |
        inclusive_range.as(:inclusive_range) |
        exclusive_range.as(:exclusive_range)
      )
    end

    rule :inclusive_range do
      str('[') >> space.maybe >>
      word.as(:from) >> space >> str('TO') >> space >> word.as(:to) >>
      space.maybe >> str(']')
    end

    rule :exclusive_range do
      str('{') >> space.maybe >>
      word.as(:from) >> space >> str('TO') >> space >> word.as(:to) >>
      space.maybe >> str('}')
    end

    rule :unary_operator do
      str('+').as(:required) |
      str('-').as(:prohibited) |
      (str('NOT').as(:op) >> space)
    end

    rule :fuzzy do
      str('~') >>
      ( str('0.') >> match['0-9'].repeat(1) | match['01'] ).maybe.as(:similarity)
    end

    rule :boost do
      str('^') >> (
        str('0.') >> match['0-9'].repeat(1) |
        match['0-9'].repeat(1)
      ).as(:boost)
    end

    rule :word do
      match["\\w"].repeat(1)
    end

    rule :space do
      match["\n \t"].repeat(1)
    end

  end
end
