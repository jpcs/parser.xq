import module namespace gr = "http://snelson.org.uk/functions/grammar" at "../grammar.xq";
import module namespace p = "http://snelson.org.uk/functions/parser" at "../parser.xq";

let $grammar := gr:grammar((
  gr:rule-("Expr","Additive"),

  gr:rule-("Additive",gr:choice("Add","Subtract","Multiplicative")),
  gr:rule("Add",("Additive",gr:term-("+"),"Multiplicative"),(),function($ch) {
    $ch[1] + $ch[2]
  }),
  gr:rule("Subtract",("Additive",gr:term-("-"),"Multiplicative"),(),function($ch) {
    $ch[1] - $ch[2]
  }),

  gr:rule-("Multiplicative",gr:choice("Multiply","Divide","Primitive")),
  gr:rule("Multiply",("Multiplicative",gr:term-("*"),"Primitive"),(),function($ch) {
    $ch[1] * $ch[2]
  }),
  gr:rule("Divide",("Multiplicative",gr:term-("/"),"Primitive"),(),function($ch) {
    $ch[1] div $ch[2]
  }),

  gr:rule-("Primitive",gr:choice("Parentheses","Number")),
  gr:rule-("Parentheses",(gr:term-("("),"Additive",gr:term-(")"))),
  gr:rule("Number",gr:one-or-more(gr:char-range("0","9")),"ws-explicit",function($ch) {
    number(codepoints-to-string($ch))
  }),

  gr:ws("S",gr:choice(
    gr:term(" "),gr:term("&#9;"),
    gr:term("&#10;"),gr:term("&#13;")))
))

let $input := '
(
  10 * (
    50 - 40
  ) / 4
)'

let $parser := p:make-parser($grammar)
let $result := $parser($input)
return (
  $result
)
