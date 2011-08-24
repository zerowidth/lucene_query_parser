module LuceneQueryParser
  class Parser < Parslet::Parser
    root :term

    rule :term do
      match["\\w'"].repeat(1).as(:term)
    end

  end
end
