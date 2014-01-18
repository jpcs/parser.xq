xquery version "1.0-ml";
import module namespace ix = "http://snelson.org.uk/functions/ixml" at "../ixml.xq";

let $grammar := '
css: -S, (rule, -S)+ .
rule: selector, -S, block.
block: "{", (property; -S)+";", "}".
property:  -S, @name, -S, ":", -S, value, -S.
selector: name.
name: +"name" .
value: +"value" .

S: (" " ; "&#9;" ; "&#10;" ; "&#13;")*.
'
let $input := "
name { name: value; name   :   value; }
"
(: let $grammar := ' :)
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
let $parser := ix:make-parser($grammar)
let $t_parser := xdmp:elapsed-time()
let $result := $parser($input)
let $t_parse := xdmp:elapsed-time()
return (
  "Parser: " || ($t_parser),
  "Parse: " || ($t_parse - $t_parser),
  $result
),
xdmp:elapsed-time()
