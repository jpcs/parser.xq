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

(: name: ... :)
(: value: ... :)
)(),
xdmp:elapsed-time()
