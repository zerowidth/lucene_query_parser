module LuceneQueryParser
  class Parser < Parslet::Parser
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
        term |
        phrase
      )
    end

    rule :term do
      match["\\w'"].repeat(1).as(:term)
    end

    rule :phrase do
      str('"') >> match['^"'].repeat(1).as(:phrase) >> str('"') >> distance |
      str('"') >> match['^"'].repeat(1).as(:phrase) >> str('"')
    end

    rule :distance do
      str('~') >> match['0-9'].repeat(1).as(:distance)
    end

    rule :group do
      str('(') >> space.maybe >> expr.as(:group) >> space.maybe >> str(')')
    end

    rule :unary_operator do
      str('+').as(:required) |
      str('-').as(:prohibited) |
      (str('NOT').as(:op) >> space)
    end

    rule :space do
      match["\n \t"].repeat(1)
    end

  end
end
