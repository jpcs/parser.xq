xquery version "1.0-ml";
import module namespace ix = "http://snelson.org.uk/functions/ixml-parser" at "../lib/ixml-parser.xq";

ix:parse(
'
css: rules .
rules: rule; rules, rule.
rule: selector, block.
block: "{", properties, "}".
properties:  property; property, ";", properties.
property:  name, ":", value; empty.
selector: name.
empty: .
'
(: ' :)
(: ixml: (rule)+. :)
(: rule: @name, -colon, -definition, -stop. :)
(: colon: -S, ":", -S. :)
(: stop: -S, ".", -S. :)
(: definition: (alternative)*-semicolon. :)
(: semicolon: -S, ";", -S. :)
(: alternative: (-term)*-comma. :)
(: comma:  -S, ",", -S. :)
(: term: -symbol; -repetition. :)
(: repetition: one-or-more; zero-or-more. :)
(: one-or-more: -open, -definition, -close, -plus, separator. :)
(: open:  -S, "(", -S. :)
(: close:  -S, ")", -S. :)
(: plus:  -S, "+", -S. :)
(: zero-or-more: -open, -definition, -close, -star, separator. :)
(: star:  -S, "*", -S. :)
(: separator: -symbol; -empty. :)
(: empty: . :)

(: symbol: -terminal; nonterminal; refinement ; attribute. :)
(: terminal: explicit-terminal; implicit-terminal. :)
(: explicit-terminal: -plus, @string. :)
(: implicit-terminal: @string. :)
(: nonterminal: @name. :)
(: refinement: -minus, @name. :)
(: minus:  -S, "-", -S. :)
(: attribute: -at, @name. :)
(: at:  -S, "@", -S. :)

(: string: -openquote, (-character)*, -closequote. :)
(: openquote: -S, """". :)
(: closequote: """", -S. :)
(: character: +"a"; +"b"; +"c". :)
(: name: (-letter)+. :)
(: letter: +"a"; +"b"; +"c". :)
(: S: " "*. :)
(: ' :)
(: name: ... :)
(: value: ... :)
)(),
xdmp:elapsed-time()
