import module namespace p = "http://snelson.org.uk/functions/parser" at "../parser.xq";

(:let $grammar := p:grammar((
  p:rule("M",("A","A","A","A")),
  p:rule("A",p:choice(p:term("a"),"E")),
  p:rule("E",())
)):)
let $grammar := p:grammar((
  p:rule-("M",p:choice("V","Apply","Define")),
  p:rule("Apply",("LP","M","M","RP")),
  p:rule("Define",("LP",p:term-("lambda"),"V","Dot","M","RP")),
  p:rule("V",p:choice(p:term("x"),p:term("y"),p:term("z"),p:term("f"),p:term("g"))),
  p:token-("LP",p:term("(")),
  p:token-("RP",p:term(")")),
  p:token-("Dot",p:term(".")),
  p:ws("S",p:choice(p:term(" "),p:term("&#9;"),p:term("&#10;"),p:term("&#13;"))),
  p:ws("Comment",(p:term("/*"),p:zero-or-more(p:term("*")),p:term("*/")))
))
(:let $grammar := p:grammar((
  p:rule("M",(p:term("zz"),p:zero-or-more(p:term("abc")))),
  p:ws("S",p:choice(p:term(" "),p:term("&#9;"),p:term("&#10;"),p:term("&#13;")))
)):)

(:let $input := "aaa":)
let $input := "( lambda f . ( lambda x . ( f/***************/ x ) ) )"
(:let $input := "zzabc abc    abc  abc
abc   abc
abcabcabcabc abc abc abc abc abc abc abc abc abc abc abc abc abc":)

let $t_grammar := xdmp:elapsed-time()
let $parser := p:make-parser($grammar)
let $t_parser := xdmp:elapsed-time()
let $result := $parser($input)
let $t_parse := xdmp:elapsed-time()
return (
  "Grammar: " || $t_grammar,
  "Parser: " || ($t_parser - $t_grammar),
  "Parse: " || ($t_parse - $t_parser),
  p:grammar-as-string($grammar),
  $result()
),
xdmp:elapsed-time()
