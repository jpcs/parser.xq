import module namespace gr = "http://snelson.org.uk/functions/grammar" at "../grammar.xq";
import module namespace p = "http://snelson.org.uk/functions/parser" at "../parser.xq";

(:let $grammar := gr:grammar((
  gr:rule("M",("A","A","A","A")),
  gr:rule("A",gr:choice(gr:term("a"),"E")),
  gr:rule("E",())
)):)
let $grammar := gr:grammar((
  gr:rule-("M",gr:choice("V","Apply","Define")),
  gr:rule("Apply",("LP","M","M","RP")),
  gr:rule("Define",("LP",gr:term-("lambda"),"V","Dot","M","RP")),
  gr:rule("V",gr:choice(gr:char-range("a","z"),gr:char-range("A","Z"))),
  gr:token-("LP",gr:term("(")),
  gr:token-("RP",gr:term(")")),
  gr:token-("Dot",gr:term(".")),
  gr:ws("S",gr:choice(gr:term(" "),gr:term("&#9;"),gr:term("&#10;"),gr:term("&#13;"))),
  gr:ws("Comment",(gr:term("/*"),gr:zero-or-more(gr:term("*")),gr:term("*/")))
))
(: let $grammar := gr:grammar(( :)
(:   gr:rule("M",("Z",gr:zero-or-more("A"))), :)
(:   gr:rule("Z",gr:term("zz")), :)
(:   gr:rule("A",gr:term("abc")), :)
(:   gr:ws("S",gr:choice(gr:term(" "),gr:term("&#9;"),gr:term("&#10;"),gr:term("&#13;"))) :)
(: )) :)

(:let $input := "aaa":)
let $input := "( lambda f . ( lambda x . ( f/***************/ x ) ) )"
(: let $input := "zzabc abc    abc  abc :)
(: abc   abc :)
(: abcabcabcabc abc abc abc abc abc abc abc abc abc abc abc abc abc" :)

let $t_grammar := xdmp:elapsed-time()
let $parser := p:make-parser($grammar)
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
(: let $t_grammar := xdmp:elapsed-time() :)
(: let $xq := p:generate-xquery($grammar,"http://snelson.org.uk/functions/invisible-xml-parser",true()) :)
(: let $t_parser := xdmp:elapsed-time() :)
(: return ( :)
(:   "Grammar: " || $t_grammar, :)
(:   "Parser: " || ($t_parser - $t_grammar), :)
(:   p:grammar-as-string($grammar), :)
(:   $xq :)
(: ), :)
xdmp:elapsed-time()
