xquery version "1.0-ml";
import module namespace ix = "http://snelson.org.uk/functions/ixml-parser" at "../lib/ixml-parser.xq";
import module namespace gr = "http://snelson.org.uk/functions/grammar" at "../grammar.xq";
import module namespace p = "http://snelson.org.uk/functions/parser" at "../parser.xq";

let $grammar := ix:parse(
'
css: -S, (rule, -S)+ .
rule: selector, -S, block.
block: -LCurly, (property; -S)+-SemiColon, -RCurly.
property:  -S, name, -S, -Colon, -S, value, -S.
selector: name.
name: +"name" .
value: +"value" .

LCurly: "{" .
RCurly: "}" .
SemiColon: ";" .
Colon: ":" .
S: (" " ; "&#9;" ; "&#10;" ; "&#13;")*.
'
)
let $input := "
name { name: value ; name   :   value }
"
(: let $grammar := ix:parse( :)
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
(: ) :)
let $t_grammar := xdmp:elapsed-time()
let $parser := p:make-parser($grammar,"eval")
let $t_parser := xdmp:elapsed-time()
let $result := $parser($input)
let $t_parse := xdmp:elapsed-time()
return (
  "Grammar: " || $t_grammar,
  "Parser: " || ($t_parser - $t_grammar),
  "Parse: " || ($t_parse - $t_parser),
  gr:grammar-as-string($grammar),
  $result()
),
xdmp:elapsed-time()
