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
        field |
        term |
        phrase
      )
    end

    rule :term do
      match["\\w'"].repeat(1).as(:term) >> fuzzy.maybe
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
      str('~').as(:fuzzy) >>
      ( str('0.') >> match['0-9'].repeat(1) | match['01'] ).maybe.as(:similarity)
    end

    rule :word do
      match["\\w"].repeat(1)
    end

    rule :space do
      match["\n \t"].repeat(1)
    end

  end
end
