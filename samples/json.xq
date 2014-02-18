import module namespace gr = "http://snelson.org.uk/functions/grammar" at "../grammar.xq";
import module namespace p = "http://snelson.org.uk/functions/parser" at "../parser.xq";

let $grammar := gr:grammar((
  gr:rule("JSON","Value"),

  gr:rule("Object",(gr:term-("{"),gr:zero-or-more("Pair",gr:term-(",")),gr:term-("}"))),
  gr:rule("Pair",("name",gr:term-(":"),"Value")),
  gr:rule-attr("name","String"),

  gr:rule("Array",(gr:term-("["),gr:zero-or-more("Value",gr:term-(",")),gr:term-("]"))),

  gr:rule-("Value",gr:choice("String","Number","Object","Array","Boolean","Null")),
  gr:rule("Boolean",gr:choice(gr:term("true"),gr:term("false")),"ws-explicit"),
  gr:rule("Null",gr:term-("null"),"ws-explicit"),

  gr:rule("String",(gr:term-('"'),gr:zero-or-more("Char"),gr:term-('"')),"ws-explicit"),

  gr:token("Char",gr:codepoint-range(0,33)),
  gr:token("Char",gr:codepoint-range(35,91)),
  gr:token("Char",gr:codepoint-range(93,1114111)),
  gr:token("Char",gr:term('\"')),
  gr:token("Char",gr:term('\\')),
  gr:token("Char",gr:term('\/')),
  gr:token("Char",gr:term('\b')),
  gr:token("Char",gr:term('\f')),
  gr:token("Char",gr:term('\n')),
  gr:token("Char",gr:term('\r')),
  gr:token("Char",gr:term('\t')),
  gr:token("Char",(gr:term('\u'),"Hex","Hex","Hex","Hex")),

  gr:token("Hex",gr:choice(gr:char-range("0","9"),gr:char-range("A","F"),gr:char-range("a","f"))),

  gr:rule("Number",(gr:optional(gr:term("-")),"Digits"),"ws-explicit"),
  gr:rule("Number",(gr:optional(gr:term("-")),"Digits",gr:term("."),"Digits"),"ws-explicit"),
  gr:rule("Number",(gr:optional(gr:term("-")),"Digits","E","Digits"),"ws-explicit"),
  gr:rule("Number",(gr:optional(gr:term("-")),"Digits",gr:term("."),"Digits","E","Digits"),"ws-explicit"),

  gr:token("Digits",gr:one-or-more(gr:char-range("0","9"))),

  gr:token("E",gr:term("e")),
  gr:token("E",gr:term("e+")),
  gr:token("E",gr:term("e-")),
  gr:token("E",gr:term("E")),
  gr:token("E",gr:term("E+")),
  gr:token("E",gr:term("E-")),

  gr:ws("S",gr:choice(
    gr:term(" "),gr:term("&#9;"),
    gr:term("&#10;"),gr:term("&#13;")))
))

let $input := '
[
        {
            "type": "home",
            "number": "212 555-1234"
        },
        {
            "type": "fax",
            "number": "646 555-4567"
        }
    ]
'

let $parser := p:make-parser($grammar)
let $result := $parser($input)
return (
  gr:grammar-as-string($grammar),
  $result()
)
