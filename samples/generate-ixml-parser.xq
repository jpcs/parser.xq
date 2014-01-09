xquery version "3.0";
import module namespace p = "http://snelson.org.uk/functions/parser" at "../parser.xq";

let $grammar := p:grammar((
(: ixml: (rule)+. :)
  p:rule("ixml",p:one-or-more("rule")),
(: rule: @name, -colon, -definition, -stop. :)
(: colon: -S, ":", -S. :)
(: stop: -S, ".", -S. :)
  p:rule("rule",("name",p:term-(":"),"definition",p:term-("."))),
(: definition: (alternative)*-semicolon. :)
(: semicolon: -S, ";", -S. :)
  p:rule-("definition",p:zero-or-more("alternative",p:term-(";"))),
(: alternative: (-term)*-comma. :)
(: comma:  -S, ",", -S. :)
  p:rule("alternative",p:zero-or-more("term",p:term-(","))),
(: term: -symbol; -repetition. :)
  p:rule("term",p:choice("symbol","repetition")),
(: repetition: one-or-more; zero-or-more. :)
  p:rule-("repetition",p:choice("one-or-more","zero-or-more")),
(: one-or-more: -open, -definition, -close, -plus, separator. :)
(: open:  -S, "(", -S. :)
(: close:  -S, ")", -S. :)
(: plus:  -S, "+", -S. :)
  p:rule("one-or-more",(p:term-("("),"definition",p:term-(")"),p:term-("+"),"separator")),
(: zero-or-more: -open, -definition, -close, -star, separator. :)
(: open:  -S, "(", -S. :)
(: close:  -S, ")", -S. :)
(: star:  -S, "*", -S. :)
  p:rule("zero-or-more",(p:term-("("),"definition",p:term-(")"),p:term-("*"),"separator")),
(: separator: -symbol; -empty. :)
(: empty: . :)
  p:rule("separator",p:optional("symbol")),

(: symbol: -terminal; nonterminal; refinement ; attribute. :)
  p:rule-("symbol",p:choice("terminal","nonterminal","refinement","attribute")),
(: terminal: explicit-terminal; implicit-terminal. :)
  p:rule-("terminal",p:choice("explicit-terminal","implicit-terminal")),
(: explicit-terminal: -plus, @string. :)
(: plus:  -S, "+", -S. :)
  p:rule("explicit-terminal",(p:term-("+"),"string")),
(: implicit-terminal: @string. :)
  p:rule("implicit-terminal","string"),
(: nonterminal: @name. :)
  p:rule("nonterminal","name"),
(: refinement: -minus, @name. :)
(: minus:  -S, "-", -S. :)
  p:rule("refinement",(p:term-("-"),"name")),
(: attribute: -at, @name. :)
(: at:  -S, "@", -S. :)
  p:rule("attribute",(p:term-("@"),"name")),

(: string: -openquote, (-character)*, -closequote. :)
(: openquote: -S, """". :)
(: closequote: """", -S. :)
(: character: ... :)
  p:token("string",(p:term-('"'),p:zero-or-more(p:codepoint-range(9,127)),p:term-('"'))),
(: name: (-letter)+. :)
(: letter: +"a"; +"b"; ... :)
  p:rule-attr("name",p:one-or-more(p:choice(p:char-range("a","z"),p:char-range("A","Z")))),

(: S: " "*. :)
  p:ws("S",p:choice(p:term(" "),p:term("&#9;"),p:term("&#10;"),p:term("&#13;")))
))
return
  p:generate-xquery($grammar,"namespace=http://snelson.org.uk/functions/ixml-parser")
