module SyntaxHelper
  def syntax(language, &block)
    Highlighter.render(language, capture(&block))
  end

  class Highlighter
    def self.render(language, syntax)
      formatter.format(lex_for(language, syntax.strip)).html_safe
    end

    private

    def self.formatter
      @@formatter ||= Rouge::Formatters::HTML.new(css_class: 'highlight')
    end

    def self.lex_for(language, syntax)
      Rouge::Lexer.find_fancy(language.to_s).lex(syntax)
    end
  end
end
