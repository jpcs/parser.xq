xquery version "3.0";
import module namespace gr = "http://snelson.org.uk/functions/grammar" at "../grammar.xq";
import module namespace p = "http://snelson.org.uk/functions/parser" at "../parser.xq";

let $grammar := gr:grammar((
(: ixml: (rule)+. :)
  gr:rule("ixml",gr:one-or-more("rule")),
(: rule: @name, -colon, -definition, -stop. :)
(: colon: -S, ":", -S. :)
(: stogr: -S, ".", -S. :)
  gr:rule("rule",("name",gr:term-(":"),"definition",gr:term-("."))),
(: definition: (alternative)*-semicolon. :)
(: semicolon: -S, ";", -S. :)
  gr:rule-("definition",gr:zero-or-more("alternative",gr:term-(";"))),
(: alternative: (-term)*-comma. :)
(: comma:  -S, ",", -S. :)
  gr:rule("alternative",gr:zero-or-more("term",gr:term-(","))),
(: term: -symbol; -repetition. :)
  gr:rule("term",gr:choice("symbol","repetition")),
(: repetition: one-or-more; zero-or-more. :)
  gr:rule-("repetition",gr:choice("one-or-more","zero-or-more")),
(: one-or-more: -open, -definition, -close, -plus, separator. :)
(: open:  -S, "(", -S. :)
(: close:  -S, ")", -S. :)
(: plus:  -S, "+", -S. :)
  gr:rule("one-or-more",(gr:term-("("),"definition",gr:term-(")"),gr:term-("+"),"separator")),
(: zero-or-more: -open, -definition, -close, -star, separator. :)
(: open:  -S, "(", -S. :)
(: close:  -S, ")", -S. :)
(: star:  -S, "*", -S. :)
  gr:rule("zero-or-more",(gr:term-("("),"definition",gr:term-(")"),gr:term-("*"),"separator")),
(: separator: -symbol; -empty. :)
(: empty: . :)
  gr:rule("separator",gr:optional("symbol")),

(: symbol: -terminal; nonterminal; refinement ; attribute. :)
  gr:rule-("symbol",gr:choice("terminal","nonterminal","refinement","attribute")),
(: terminal: explicit-terminal; implicit-terminal. :)
  gr:rule-("terminal",gr:choice("explicit-terminal","implicit-terminal")),
(: explicit-terminal: -plus, @string. :)
(: plus:  -S, "+", -S. :)
  gr:rule("explicit-terminal",(gr:term-("+"),"string")),
(: implicit-terminal: @string. :)
  gr:rule("implicit-terminal","string"),
(: nonterminal: @name. :)
  gr:rule("nonterminal","name"),
(: refinement: -minus, @name. :)
(: minus:  -S, "-", -S. :)
  gr:rule("refinement",(gr:term-("-"),"name")),
(: attribute: -at, @name. :)
(: at:  -S, "@", -S. :)
  gr:rule("attribute",(gr:term-("@"),"name")),

(: string: -openquote, (-character)*, -closequote. :)
(: openquote: -S, """". :)
(: closequote: """", -S. :)
(: character: ... :)
  gr:token("string",(gr:term-('"'),gr:zero-or-more(gr:choice(gr:codepoint-range(9,33),gr:codepoint-range(35,127))),gr:term-('"'))),
(: name: (-letter)+. :)
(: letter: +"a"; +"b"; ... :)
  gr:rule-attr("name",gr:one-or-more(gr:choice(gr:char-range("a","z"),gr:char-range("A","Z")))),

(: S: " "*. :)
  gr:ws("S",gr:choice(gr:term(" "),gr:term("&#9;"),gr:term("&#10;"),gr:term("&#13;")))
))
return
  p:generate-xquery($grammar,"namespace=http://snelson.org.uk/functions/ixml-parser")
