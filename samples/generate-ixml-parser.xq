xquery version "3.0";
import module namespace gr = "http://snelson.org.uk/functions/grammar" at "../grammar.xq";
import module namespace p = "http://snelson.org.uk/functions/parser" at "../parser.xq";

let $grammar := gr:grammar((
(: ixml: (rule)+. :)
  gr:rule("ixml",gr:one-or-more("rule"),(),
    "gr:grammar($ch)"
  ),

(: rule: @name, -colon, -definition, -stop. :)
(: colon: -S, ":", -S. :)
(: stogr: -S, ".", -S. :)
  gr:rule("rule",("name",gr:term-(":"),"definition",gr:term-(".")),(),
    "gr:rule(fn:head($ch),fn:tail($ch))"
  ),

(: definition: (alternative)*-semicolon. :)
(: semicolon: -S, ";", -S. :)
  gr:rule("definition",gr:zero-or-more("alternative",gr:term-(";")),(),
    "gr:nchoice($ch)"
  ),

(: alternative: (-term)*-comma. :)
(: comma:  -S, ",", -S. :)
  gr:rule("alternative",gr:zero-or-more("term",gr:term-(",")),(),
    "gr:sequence($ch)" (: TBD -, @, etc. :)
  ),

(: term: -symbol; -repetition. :)
  gr:rule("term",gr:choice("symbol","repetition"),(),
    "$ch"
  ),

(: repetition: one-or-more; zero-or-more. :)
  gr:rule("repetition",gr:choice("one-or-more","zero-or-more"),(),
    "$ch"
  ),

(: one-or-more: -open, -definition, -close, -plus, separator. :)
(: open:  -S, "(", -S. :)
(: close:  -S, ")", -S. :)
(: plus:  -S, "+", -S. :)
  gr:rule("one-or-more",(gr:term-("("),"definition",gr:term-(")"),gr:term-("+"),"separator"),(),
    "gr:one-or-more($ch[1],$ch[2])"
  ),

(: zero-or-more: -open, -definition, -close, -star, separator. :)
(: open:  -S, "(", -S. :)
(: close:  -S, ")", -S. :)
(: star:  -S, "*", -S. :)
  gr:rule("zero-or-more",(gr:term-("("),"definition",gr:term-(")"),gr:term-("*"),"separator"),(),
    "gr:zero-or-more($ch[1],$ch[2])"
  ),

(: separator: -symbol; -empty. :)
(: empty: . :)
  gr:rule("separator",gr:choice("symbol","no-separator"),(),
    "$ch"
  ),
  gr:rule("no-separator",(),(),
    "()"
  ),

(: symbol: -terminal; nonterminal; refinement ; attribute. :)
  gr:rule("symbol",gr:choice("terminal","nonterminal","refinement","attribute"),(),
    "$ch"
  ),

(: terminal: explicit-terminal; implicit-terminal. :)
  gr:rule("terminal",gr:choice("explicit-terminal","implicit-terminal"),(),
    "$ch"
  ),

(: explicit-terminal: -plus, @string. :)
(: plus:  -S, "+", -S. :)
  gr:rule("explicit-terminal",(gr:term-("+"),"string"),(),
    "gr:term($ch)"
  ),

(: implicit-terminal: @string. :)
  gr:rule("implicit-terminal","string",(),
    "gr:term-($ch)"
  ),

(: nonterminal: @name. :)
  gr:rule("nonterminal","name",(),
    "gr:non-term($ch)"
  ),

(: refinement: -minus, @name. :)
(: minus:  -S, "-", -S. :)
  gr:rule("refinement",(gr:term-("-"),"name"),(),
    "gr:non-term($ch)" (: TBD :)
  ),

(: attribute: -at, @name. :)
(: at:  -S, "@", -S. :)
  gr:rule("attribute",(gr:term-("@"),"name"),(),
    "gr:non-term($ch)" (: TBD :)
  ),

(: string: -openquote, (-character)*, -closequote. :)
(: openquote: -S, """". :)
(: closequote: """", -S. :)
(: character: ... :)
  gr:rule("string",(gr:term-('"'),gr:zero-or-more(gr:choice(gr:codepoint-range(9,33),gr:codepoint-range(35,127))),gr:term-('"')),"ws-explicit",
    "fn:codepoints-to-string($ch)"
  ),

(: name: (-letter)+. :)
(: letter: +"a"; +"b"; ... :)
  gr:rule("name",gr:one-or-more(gr:choice(gr:char-range("a","z"),gr:char-range("A","Z"))),(),
    "fn:codepoints-to-string($ch)"
  ),

(: S: " "*. :)
  gr:ws("S",gr:choice(gr:term(" "),gr:term("&#9;"),gr:term("&#10;"),gr:term("&#13;")))
))
return
  p:generate-xquery($grammar,"namespace=http://snelson.org.uk/functions/ixml-parser")
