xquery version "3.0";

(:
 : Copyright (c) 2013 John Snelson
 :
 : Licensed under the Apache License, Version 2.0 (the "License");
 : you may not use this file except in compliance with the License.
 : You may obtain a copy of the License at
 :
 :     http://www.apache.org/licenses/LICENSE-2.0
 :
 : Unless required by applicable law or agreed to in writing, software
 : distributed under the License is distributed on an "AS IS" BASIS,
 : WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 : See the License for the specific language governing permissions and
 : limitations under the License.
 :)

module namespace p = "http://snelson.org.uk/functions/parser";
declare default function namespace "http://snelson.org.uk/functions/parser";
declare namespace err = "http://www.w3.org/2005/xqt-errors";
import module namespace map = "http://snelson.org.uk/functions/hashmap" at "lib/hashmap.xq";
import module namespace array = "http://snelson.org.uk/functions/array" at "lib/array.xq";
import module namespace hamt = "http://snelson.org.uk/functions/hamt" at "lib/hamt.xq";
import module namespace pr = "http://snelson.org.uk/functions/parser-runtime" at "parser-runtime.xq";

(:
 : Grammar = map(string,Rule)
 : Rule = (integer, RuleSet)
 : RuleSet = hamt(RuleRHS)
 : RuleRHS = Category* boolean ActionFunction
 : ActionFunction = function(item()*) as item()*
 : Category = NT integer string | T integer integer | TR integer integer integer
 :)

declare variable $ws-state := "<ws>";
declare variable $ws-category := category-nt("<ws>");
declare variable $epsilon-state := "<epsilon>";
declare variable $epsilon-category := category-nt("<epsilon>");

declare variable $epsilon-id := 0;
declare variable $ws-id := 1;
declare variable $start-id := 2;

declare variable $ws-option := "ws-explicit";

declare %private variable $isMarkLogic as xs:boolean external :=
  fn:exists(fn:function-lookup(fn:QName("http://marklogic.com/xdmp","functions"),0));

declare %private variable $log := (
  fn:function-lookup(fn:QName("http://marklogic.com/xdmp","log"),1),
  function($s) { () }
)[1];

declare %private variable $eval := (
  fn:function-lookup(fn:QName("http://marklogic.com/xdmp","eval"),1),
  function($s) { fn:error(xs:QName("p:EVAL"),"Eval function unknown for this XQuery processor") }
)[1];

(: -------------------------------------------------------------------------- :)
(: Built-In Actions :)

declare %private variable $parse-default-actions := (
  discard#1,
  (: fn:codepoints-to-string#1, :)
  children#1,
  children#1,
  children#1,
  function($n) { tree($n,?) },
  function($n) { attr($n,?) }
);

declare function tree($n,$ch)
{
  function() {
    element { $n } {
      $ch ! (
        typeswitch(.)
        case xs:string return text { . }
        case xs:integer return text { fn:codepoints-to-string(.) }
        default return .()
      )
    }
  }
};

declare function attr($n,$ch)
{
  function() {
    attribute { $n } { fn:string-join(
      $ch ! (
        typeswitch(.)
        case xs:string return .
        case xs:integer return fn:codepoints-to-string(.)
        default return .() ! fn:string(.)
      )
    )}
  }
};

declare function children($ch)
{
  $ch
};

declare function discard($ch)
{
  ()
};

declare %private variable $generate-default-actions := (
  "()",
  "$ch",
  "$ch",
  "$ch",
  function($n) {
    if(try { fn:empty(xs:NCName($n)) } catch * { fn:true() }) then
      fn:error(xs:QName("p:BADNAME"),"Invalid rule name: " || $n)
    else "function() {
      element " || $n || " { $ch ! (
        typeswitch(.)
        case xs:string return text { . }
        case xs:integer return text { fn:codepoints-to-string(.) }
        default return .()
      )}
    }"
  },
  function($n) {
    if(try { fn:empty(xs:NCName($n)) } catch * { fn:true() }) then
      fn:error(xs:QName("p:BADNAME"),"Invalid rule name: " || $n)
    else "function() {
      attribute " || $n || " { fn:string-join($ch ! (
        typeswitch(.)
        case xs:string return .
        case xs:integer return fn:codepoints-to-string(.)
        default return .() ! fn:string(.)
      ))}
    }"
  }
);

(: -------------------------------------------------------------------------- :)

declare %private function category-nt($n)
{
  let $hash := hash((fn:string-to-codepoints($n),0))
  return function($nt,$t,$tr) { $nt($hash,$n) }
};

declare %private function category-t($n)
{
  let $hash := hash((8945782,$n))
  return function($nt,$t,$tr) { $t($hash,$n) }
};

declare %private function category-tr($s,$e)
{
  let $hash := hash((78906239,$s,$e))
  return function($nt,$t,$tr) { $tr($hash,$s,$e) }
};

declare %private function hash-fuse($z,$v) as xs:integer
{
  xs:integer((($z * 5) + $v) mod 4294967296)
};

declare %private function hash($a as xs:integer*) as xs:integer
{
  fn:fold-left(hash-fuse#2,2489012344,$a)
};

declare %private function categories-hash($a as item()*) as xs:integer
{
  hash($a ! .(
    (:nt:) function($h,$s) { $h },
    (:t:) function($h,$s) { $h },
    (:tr:) function($h,$s,$e) { $h }
  ))
};

declare %private function categories-eq($a as item()*, $b as item()*) as xs:boolean
{
  fn:count($a) eq fn:count($b) and
  (every $p in fn:map-pairs(function($x,$y) {
      $x(
        (:nt:) function($xh,$xs) {
          $y(
            (:nt:) function($yh,$ys) { $xs eq $ys },
            (:t:) function($yh,$ys) { fn:false() },
            (:tr:) function($yh,$ys,$ye) { fn:false() }
          )
        },
        (:t:) function($xh,$xs) {
          $y(
            (:nt:) function($yh,$ys) { fn:false() },
            (:t:) function($yh,$ys) { $xs eq $ys },
            (:tr:) function($yh,$ys,$ye) { fn:false() }
          )
        },
        (:tr:) function($xh,$xs,$xe) {
          $y(
            (:nt:) function($yh,$ys) { fn:false() },
            (:t:) function($yh,$ys) { fn:false() },
            (:tr:) function($yh,$ys,$ye) { $xs eq $ys and $xe eq $ye }
          )
        }
      )
    },$a,$b) satisfies $p)
};

declare %private function rulerhs($categories,$ws,$f)
{
  function($g) { $g($categories,$ws,$f) }
};

declare %private function rulerhs-hash($a as item()) as xs:integer
{
  $a(function($c,$ws,$f) {
    hash((categories-hash($c),xs:integer($ws)))
  })
};

declare %private function rulerhs-eq($a as item(), $b as item()) as xs:boolean
{
  $a(function($ac,$aws,$af) {
    $b(function($bc,$bws,$bf) {
      categories-eq($ac,$bc) and $aws eq $bws
    })
  })
};

declare %private function ruleset() as item()
{
  hamt:create()
};

declare %private function ruleset-put(
  $set as item(),
  $rule
) as item()
{
  hamt:put(rulerhs-hash#1,rulerhs-eq#2,$set,$rule)
};

declare %private function ruleset-fold(
  $f as function(item()*, item()*) as item()*,
  $z as item()*,
  $set as item()
) as item()*
{
  hamt:fold($f,$z,$set)
};

(: -------------------------------------------------------------------------- :)

(:
 : Grammar construction functions
 :)

declare %private function codepoint($c)
{
  switch($c)
  case 0 return "\0"
  case 9 return "\t"
  case 10 return "\n"
  case 13 return "\r"
  case 34 return '\"'
  case 92 return "\\"
  default return fn:codepoints-to-string($c)
};

declare %private function codepoint-xq($c)
{
  switch($c)
  case 0 return "\0"
  case 9 return "\t"
  case 10 return "\n"
  case 13 return "\r"
  case 34 return "\&amp;quot;"
  case 92 return "\\"
  default return fn:codepoints-to-string($c)
};

declare %private function categories-as-string($cs)
{
  for $c in fn:head($cs)
  return $c(
    (:nt:) function($h,$s) {
      $s,
      categories-as-string(fn:tail($cs))
    },
    (:t:) function($h,$s) {
      let $r := combine-terminals-as-string(fn:tail($cs))
      return (
        ('"' || codepoint($s) || fn:head($r) || '"'),
        categories-as-string(fn:tail($r))
      )
    },
    (:tr:) function($h,$s,$e) {
      "[" || codepoint($s) || "-" || codepoint($e) || "]",
      categories-as-string(fn:tail($cs))
    }
  )
};

declare %private function combine-terminals-as-string($cs)
{
  for $c in fn:head($cs)
  return $c(
    (:nt:) function($h,$s) { "", $cs },
    (:t:) function($h,$s) {
      let $r := combine-terminals-as-string(fn:tail($cs))
      return ((codepoint($s) || fn:head($r)), fn:tail($r))
    },
    (:tr:) function($h,$s,$e) { "", $cs }
  )
};

declare function grammar-as-string($grammar)
{
  let $grammar := $grammar($p:parse-default-actions)
  return fn:string-join(
    for $r in map:fold(function($z,$n,$rule) { $z,function() { $n,$rule } },(),$grammar)
    let $r_ := $r()
    let $n := fn:head($r_)
    let $r_ := fn:tail($r_)
    let $id := fn:head($r_)
    let $ruleset := fn:tail($r_)
    where $id ne $p:epsilon-id
    order by $id
    return (
      "(" || $id || ") " || $n || " ::= " ||
      fn:string-join(
        ruleset-fold(function($s,$rule) {
          $s,
          $rule(function($c,$ws,$f) {
            (if(fn:not($ws)) then "ws-explicit(" else "") ||
            fn:string-join(categories-as-string($c)," ") ||
            (if(fn:not($ws)) then ")" else "")
          })
        },(),$ruleset),
      " | ")
    ),
  "&#10;")
};

declare %private function make-rules($n,$i,$c,$r,$ws,$f,$df)
{
  if(fn:empty($r)) then ($i,function($g) { $g($n,$c,$ws,$f) })
  else fn:head($r)($n,$i,$c,fn:tail($r),$ws,$f,$df)
};

declare %private function chain($i,$fns)
{
  if(fn:empty($fns)) then $i else
  let $r1 := fn:head($fns)($i)
  let $r2 := chain(fn:head($r1),fn:tail($fns))
  return (fn:head($r2),fn:tail($r1),fn:tail($r2))
};

declare function codepoint-range($start,$end)
{
  function($n,$i,$c,$r,$ws,$f,$df) {
    make-rules($n,$i,($c,category-tr($start,$end)),$r,$ws,$f,$df)
  }
};

declare function char-range($start_,$end_)
{
  let $start := fn:string-to-codepoints($start_) treat as xs:integer
  let $end := fn:string-to-codepoints($end_) treat as xs:integer
  return codepoint-range($start,$end)
};

declare function term($value)
{
  function($n,$i,$c,$r,$ws,$f,$df) {
    if(fn:string-length($value) eq 1 or fn:not($ws)) then (
      make-rules($n,$i,($c,fn:string-to-codepoints($value) ! category-t(.)),$r,$ws,$f,$df)
    ) else (
      let $n_ := $n || "_" || $i
      let $nt := non-term($n_)
      return (
        make-rules($n,$i+1,$c,($nt,$r),$ws,$f,$df),
        fn:tail(make-rules($n_,1,fn:string-to-codepoints($value) ! category-t(.),(),fn:false(),
          $df[2],$df))
      )
    )
  }
};

declare function term-($value)
{
  function($n,$i,$c,$r,$ws,$f,$df) {
    let $n_ := $n || "_" || $i
    let $nt := non-term($n_)
    return (
      make-rules($n,$i+1,$c,($nt,$r),$ws,$f,$df),
      fn:tail(make-rules($n_,1,fn:string-to-codepoints($value) ! category-t(.),(),fn:false(),
        $df[1],$df))
    )
  }
};

declare function non-term($value)
{
  function($n,$i,$c,$r,$ws,$f,$df) {
    make-rules($n,$i,($c,category-nt($value)),$r,$ws,$f,$df)
  }
};

declare function optional($b)
{
  let $b_ := make-non-terms($b)
  return function($n,$i,$c,$r,$ws,$f,$df) {
    chain($i,(
      make-rules($n,?,$c,$r,$ws,$f,$df),
      make-rules($n,?,$c,($b_,$r),$ws,$f,$df)
    ))
  }
};

declare function one-or-more($b)
{
  one-or-more($b,())
};

declare function one-or-more($b,$s)
{
  let $b_ := make-non-terms($b)
  let $s_ := make-non-terms($s)
  return function($n,$i,$c,$r,$ws,$f,$df) {
    let $n_ := $n || "_" || $i
    let $nt := non-term($n_)
    return (
      make-rules($n,$i+1,$c,($nt,$r),$ws,$f,$df),
      fn:tail(chain(1,(
        make-rules($n_,?,(),$b_,$ws,$df[4],$df),
        make-rules($n_,?,(),($nt,$s_,$b_),$ws,$df[4],$df)
      )))
    )
  }
};

declare function zero-or-more($b)
{
  let $b_ := make-non-terms($b)
  return function($n,$i,$c,$r,$ws,$f,$df) {
    let $n_ := $n || "_" || $i
    let $nt := non-term($n_)
    return (
      make-rules($n,$i+1,$c,($nt,$r),$ws,$f,$df),
      fn:tail(chain(1,(
        make-rules($n_,?,(),(),$ws,$df[4],$df),
        make-rules($n_,?,(),($nt,$b_),$ws,$df[4],$df)
      )))
    )
  }
};

declare function zero-or-more($b,$s)
{
  optional(one-or-more($b,$s))
};

declare function choice($b1,$b2)
{
  let $b1_ := make-non-terms($b1)
  let $b2_ := make-non-terms($b2)
  return function($n,$i,$c,$r,$ws,$f,$df) {
    chain($i,(
      make-rules($n,?,$c,($b1_,$r),$ws,$f,$df),
      make-rules($n,?,$c,($b2_,$r),$ws,$f,$df)
    ))
  }
};

declare function choice($b1,$b2,$b3)
{
  let $b1_ := make-non-terms($b1)
  let $b2_ := make-non-terms($b2)
  let $b3_ := make-non-terms($b3)
  return function($n,$i,$c,$r,$ws,$f,$df) {
    chain($i,(
      make-rules($n,?,$c,($b1_,$r),$ws,$f,$df),
      make-rules($n,?,$c,($b2_,$r),$ws,$f,$df),
      make-rules($n,?,$c,($b3_,$r),$ws,$f,$df)
    ))
  }
};

declare function choice($b1,$b2,$b3,$b4)
{
  let $b1_ := make-non-terms($b1)
  let $b2_ := make-non-terms($b2)
  let $b3_ := make-non-terms($b3)
  let $b4_ := make-non-terms($b4)
  return function($n,$i,$c,$r,$ws,$f,$df) {
    chain($i,(
      make-rules($n,?,$c,($b1_,$r),$ws,$f,$df),
      make-rules($n,?,$c,($b2_,$r),$ws,$f,$df),
      make-rules($n,?,$c,($b3_,$r),$ws,$f,$df),
      make-rules($n,?,$c,($b4_,$r),$ws,$f,$df)
    ))
  }
};

declare function choice($b1,$b2,$b3,$b4,$b5)
{
  let $b1_ := make-non-terms($b1)
  let $b2_ := make-non-terms($b2)
  let $b3_ := make-non-terms($b3)
  let $b4_ := make-non-terms($b4)
  let $b5_ := make-non-terms($b5)
  return function($n,$i,$c,$r,$ws,$f,$df) {
    chain($i,(
      make-rules($n,?,$c,($b1_,$r),$ws,$f,$df),
      make-rules($n,?,$c,($b2_,$r),$ws,$f,$df),
      make-rules($n,?,$c,($b3_,$r),$ws,$f,$df),
      make-rules($n,?,$c,($b4_,$r),$ws,$f,$df),
      make-rules($n,?,$c,($b5_,$r),$ws,$f,$df)
    ))
  }
};

declare function choice($b1,$b2,$b3,$b4,$b5,$b6)
{
  let $b1_ := make-non-terms($b1)
  let $b2_ := make-non-terms($b2)
  let $b3_ := make-non-terms($b3)
  let $b4_ := make-non-terms($b4)
  let $b5_ := make-non-terms($b5)
  let $b6_ := make-non-terms($b6)
  return function($n,$i,$c,$r,$ws,$f,$df) {
    chain($i,(
      make-rules($n,?,$c,($b1_,$r),$ws,$f,$df),
      make-rules($n,?,$c,($b2_,$r),$ws,$f,$df),
      make-rules($n,?,$c,($b3_,$r),$ws,$f,$df),
      make-rules($n,?,$c,($b4_,$r),$ws,$f,$df),
      make-rules($n,?,$c,($b5_,$r),$ws,$f,$df),
      make-rules($n,?,$c,($b6_,$r),$ws,$f,$df)
    ))
  }
};

declare %private function make-non-terms($categories)
{
  for $c in $categories
  return typeswitch($c)
    case xs:string return non-term($c)
    default return $c
};

declare function rule($n,$categories)
{
  rule($n,$categories,())
};

declare function rule-($n,$categories)
{
  rule-($n,$categories,())
};

declare function rule-attr($n,$categories)
{
  rule-attr($n,$categories,())
};

declare function rule($n,$categories,$options)
{
  let $ws := fn:not($options = $p:ws-option)
  return function($df) {
    fn:tail(make-rules($n,1,(),make-non-terms($categories),$ws,$df[5]($n),$df))
  }
};

declare function rule-($n,$categories,$options)
{
  let $ws := fn:not($options = $p:ws-option)
  return function($df) {
    fn:tail(make-rules($n,1,(),make-non-terms($categories),$ws,$df[4],$df))
  }
};

declare function rule-attr($n,$categories,$options)
{
  let $ws := fn:not($options = $p:ws-option)
  return function($df) {
    fn:tail(make-rules($n,1,(),make-non-terms($categories),$ws,$df[6]($n),$df))
  }
};

declare function rule($n,$categories,$options,$f)
{
  let $ws := fn:not($options = $p:ws-option)
  return function($df) {
    fn:tail(make-rules($n,1,(),make-non-terms($categories),$ws,$f,$df))
  }
};

declare function token($n,$categories)
{
  function($df) {
    fn:tail(make-rules($n,1,(),make-non-terms($categories),fn:false(),$df[3],$df))
  }
};

declare function token-($n,$categories)
{
  function($df) {
    fn:tail(make-rules($n,1,(),make-non-terms($categories),fn:false(),$df[1],$df))
  }
};

declare function ws($n,$categories)
{
  function($df) {
    rule($n,$categories,$p:ws-option,$df[1])($df),
    rule($p:ws-state,$n,$p:ws-option,$df[1])($df)
  }
};

declare function ws($n,$categories,$f)
{
  function($df) {
    rule($n,$categories,$p:ws-option,$f)($df),
    rule($p:ws-state,$n,$p:ws-option,$df[1])($df)
  }
};

declare function grammar($rules)
{
  grammar($rules,?)
};

declare %private function grammar($rules,$df)
{
  let $rules := $rules ! .($df)
  let $map := fn:fold-left(
    function($map,$rule) {
      $rule(function($category,$categories,$ws,$f) {
        let $rule := map:get($map,$category)
        let $id :=
          if($category eq $p:ws-state) then $p:ws-id
          else if(fn:exists($rule)) then fn:head($rule)
          else (map:count($map) + $p:start-id)
        let $set := if(fn:exists($rule)) then fn:tail($rule) else ruleset()
        return map:put($map,$category,($id,ruleset-put($set,rulerhs($categories,$ws,$f))))
      })
    },
    map:create(),
    $rules
  )
  return map:put($map,$p:epsilon-state,($p:epsilon-id))
};

declare %private function grammar-get($grammar,$category)
{
  let $rule := map:get($grammar,$category)
  where fn:exists($rule)
  return ruleset-fold(function($s,$c){ $s,$c },(),fn:tail($rule))
};

declare %private function grammar-get-id($grammar,$category)
{
  let $rule := map:get($grammar,$category)
  where fn:exists($rule)
  return fn:head($rule)
};

declare %private function category-nullable($grammar,$category)
{
  category-nullable($grammar,$category,())
};

declare %private function category-nullable($grammar,$category,$searched)
{
  if($category = $searched) then fn:true() else
  some $rule in grammar-get($grammar,$category)
  satisfies
    (every $rc in $rule(function($c,$ws,$f) { $c }) satisfies $rc(
      (:nt:) function($h,$s) { fn:true() },
      (:t:) function($h,$s) { fn:false() },
      (:tr:) function($h,$s,$e) { fn:false() }
    )) and
    (every $rc in $rule(function($c,$ws,$f) { $c }) satisfies $rc(
      (:nt:) function($h,$s) { category-nullable($grammar,$s,($searched,$category)) },
      (:t:) function($h,$s) { fn:false() },
      (:tr:) function($h,$s,$e) { fn:false() }
    ))
};

(: -------------------------------------------------------------------------- :)

(:
 : DottedRuleSet = hamt(DottedRule)
 : DottedRule = string Category* Category* boolean integer ActionFunction
 :)

declare %private function dotted-rule($n,$c,$ws,$f)
{
  dotted-rule($n,(),$c,$ws,$f)
};

declare %private function dotted-rule($n,$cb,$ca,$ws,$f)
{
  let $h := hash((
      fn:string-to-codepoints($n),
      categories-hash($ca),
      xs:integer($ws)
    )) 
  return function($g) { $g($n,$cb,$ca,$ws,$h,$f) }
};

declare %private function dotted-rule-hash($a as item()) as xs:integer { $a(function($n,$cb,$ca,$ws,$h,$f) { $h }) };

declare %private function dotted-rule-eq($a as item(), $b as item()) as xs:boolean
{
  $a(function($n1,$cb1,$ca1,$ws1,$h1,$f1) {
    $b(function($n2,$cb2,$ca2,$ws2,$h2,$f2) {
      $n1 eq $n2 and
      $ws1 eq $ws2 and
      categories-eq($ca1,$ca2)
    })
  })
};

declare function dotted-ruleset() as item()
{
  hamt:create()
};

declare function dotted-ruleset-put(
  $set as item(),
  $dotted-rule
) as item()
{
  hamt:put(dotted-rule-hash#1, dotted-rule-eq#2, $set, $dotted-rule)
};

declare function dotted-ruleset-contains(
  $set as item(),
  $dotted-rule
) as item()
{
  hamt:contains(dotted-rule-hash#1, dotted-rule-eq#2, $set, $dotted-rule)
};

declare function dotted-ruleset-fold(
  $f as function(item()*, item()) as item()*,
  $z as item()*,
  $set as item()
) as item()*
{
  hamt:fold($f,$z,$set)
};

declare function dotted-ruleset-hash($set as item()) as xs:integer
{
  hash(
    for $h in dotted-ruleset-fold(function($h,$dr) { $h, dotted-rule-hash($dr) },(),$set)
    order by $h
    return $h
  )
};

(: -------------------------------------------------------------------------- :)

(:
 : States = array(integer,State) array(state-hash(State),integer) hamt(PendingEdge) array(integer,string)
 : PendingEdge = integer, Category
 : State = DottedRuleSet array(integer,integer) array(integer,integer) (integer,ActionFunction)* integer
 :)

declare %private function states-as-string($s)
{
  $s(function($states,$statemap,$pending,$names) {
    fn:string-join((
      for $id in (0 to (array:size($states)-1))
      let $state := array:get($states,$id)
      return
        $state(function($drs,$nte,$te,$tre,$fns,$h) {
          "State " || $id || " (" || $h || ")",
          dotted-ruleset-fold(function($s,$dr) {
            $s,
            $dr(function($n,$cb,$ca,$ws,$h,$f) {
              "  " || $n || " ::= " ||
              (if(fn:not($ws)) then "ws-explicit(" else "") ||
              fn:string-join($cb ! categories-as-string(.)," ") ||
              "." ||
              fn:string-join($ca ! categories-as-string(.)," ") ||
              (if(fn:not($ws)) then ")" else "")
            })
          },(),$drs),
          array:fold(function($s,$nt,$sid) {
            $s, "    edge: " || $nt || " -> " || $sid
          },(),$nte),
          array:fold(function($s,$t,$sid) {
            $s, "    edge: '" || codepoint($t) || "' -> " ||
            fn:string-join($sid ! fn:string(.),", ")
          },(),$te),
          for $e in $tre return $e(function($s,$e,$sid) {
            "    edge: [" || codepoint($s) || "-" || codepoint($e) || "] -> " || $sid
          }),
          $fns ! ("    complete: " || fn:head(.()))
        }),
      hamt:fold(function($s,$pe) {
        $s,$pe(function($s,$c) {
          "pending edge state: " || $s || ", category: " || categories-as-string($c)
        })
      },(),$pending)
    ),"&#10;")
  })
};

declare %private function states($grammar)
{
  let $states := array:create()
  let $statemap := array:create()
  let $pending := hamt:create()
  let $names := map:fold(function($names,$category,$rule) {
    array:put($names,fn:head($rule),$category)
  },array:create(),$grammar)
  return function($f) { $f($states,$statemap,$pending,$names) }
};

declare %private function states-get($s,$id)
{
  $s(function($states,$statemap,$pending,$names) {
    array:get($states,$id)
  })
};

declare %private function states-add-state($s,$grammar,$state,$pe)
{
  $s(function($states,$statemap,$pending,$names) {
    $state(function($drs,$nte,$te,$tre,$fns,$h) {
      let $id := array:get($statemap,$h)
      return if(fn:exists($id)) then
        let $states_ := if(fn:empty($pe)) then $states else
          statesarray-add-edge($states,$grammar,$pe,$id)
        let $pending_ := if(fn:empty($pe)) then $pending else
          hamt:delete(pending-edge-hash#1,pending-edge-eq#2,$pending,$pe)
        return ($id,function($f) { $f($states_,$statemap,$pending_,$names) })
      else 
        let $id := array:size($states)
        let $states_ := array:put($states,$id,$state)
        let $statemap_ := array:put($statemap,$h,$id)
        let $states_ := if(fn:empty($pe)) then $states_ else
          statesarray-add-edge($states_,$grammar,$pe,$id)
        let $pending_ := dotted-ruleset-fold(function($p,$dr) {
            $dr(function($n,$cb,$ca,$ws,$h,$f) {
              if(fn:empty($ca)) then $p else
              hamt:put(pending-edge-hash#1,pending-edge-eq#2,$p,pending-edge($id,fn:head($ca)))
            })
          },$pending,$drs)
        let $ws := fn:exists(grammar-get($grammar,$p:ws-state)) and
          dotted-ruleset-fold(function($b,$dr) {
            $b or $dr(function($n,$cb,$ca,$ws,$h,$f) { $ws }) },fn:false(),$drs)
        let $pending_ := if(fn:not($ws)) then $pending_ else
          hamt:put(pending-edge-hash#1,pending-edge-eq#2,$pending_,
            pending-edge($id,$p:ws-category))
        let $pending_ := if(fn:empty($pe)) then $pending_ else
          hamt:delete(pending-edge-hash#1,pending-edge-eq#2,$pending_,$pe)
        return ($id,function($f) { $f($states_,$statemap_,$pending_,$names) })
    })
  })
};

declare %private function statesarray-add-edge($states,$grammar,$pe,$id)
{
  $pe(function($s,$c) {
    array:put($states,$s,state-add-edge(array:get($states,$s),$grammar,$c,$id))
  })
};

declare %private function states-next-pending-edge($s)
{
  $s(function($states,$statemap,$pending,$names) {
    hamt:fold(function($r,$pe) { $pe },(),$pending)
  })
};

declare %private function pending-edge($s,$c) { function($f) { $f($s,$c) } };

declare %private function pending-edge-hash($a as item()) as xs:integer
{
  $a(function($s,$c) {
    hash(($s,categories-hash($c)))
  })
};

declare %private function pending-edge-eq($a as item(), $b as item()) as xs:boolean
{
  $a(function($s1,$c1) {
    $b(function($s2,$c2) {
      $s1 eq $s2 and
      categories-eq($c1,$c2)
    })
  })
};

declare %private function state($grammar,$drs)
{
  let $nte := array:create()
  let $te := array:create()
  let $tre := ()
  let $cs := fn:distinct-values(dotted-ruleset-fold(function($cs,$dr) {
    $cs,
    $dr(function($n,$cb,$ca,$ws,$h,$f) {
      if(fn:exists($ca)) then () else grammar-get-id($grammar,$n)
    })
  },(),$drs))
  let $fns := for $c in $cs
    return dotted-ruleset-fold(function($r,$dr) {
      $dr(function($n,$cb,$ca,$ws,$h,$f) {
        if(fn:exists($ca) or grammar-get-id($grammar,$n) ne $c) then $r
        else function() { $c, $f }
      })
    },(),$drs)
  let $h := dotted-ruleset-hash($drs)
  return function($f) { $f($drs,$nte,$te,$tre,$fns,$h) }
};

declare %private function state-hash($a as item()) as xs:integer { $a(function($drs,$nte,$te,$fns,$h) { $h }) };

declare %private function state-eq($a as item(), $b as item()) as xs:boolean
{
  $a(function($drs1,$nte1,$te1,$tre1,$fns1,$h1) {
    $b(function($drs2,$nte2,$te2,$tre2,$fns2,$h2) {
      $h1 eq $h2
    })
  })
};

declare %private function te-add($te,$s,$id)
{
  array:put($te,$s,($id,array:get($te,$s)))
};

declare %private function tre-add($tre,$s,$e,$id)
{
  function($f) { $f($s,$e,$id) }, $tre
};

declare %private function state-add-edge($state,$grammar,$c,$id)
{
  $state(function($drs,$nte,$te,$tre,$fns,$h) {
    $c(
      (:nt:) function($h,$category) {
        let $cid := grammar-get-id($grammar,$category)
        let $nte := array:put($nte,$cid,$id)
        return function($f) { $f($drs,$nte,$te,$tre,$fns,$h) }
      },
      (:t:) function($h,$s) {
        let $te := te-add($te,$s,$id)
        return function($f) { $f($drs,$nte,$te,$tre,$fns,$h) }
      },
      (:tr:) function($h,$s,$e) {
        let $tre := tre-add($tre,$s,$e,$id)
        return function($f) { $f($drs,$nte,$te,$tre,$fns,$h) }
      }
    )
  })
};

(: -------------------------------------------------------------------------- :)

(:
 : Split Epsilon-DFA production
 : http://webhome.cs.uvic.ca/~nigelh/Publications/PracticalEarleyParsing.pdf
 :)

declare %private function dfa($grammar)
{
  let $drs := map:fold(function($r,$category,$rule) {
    if(fn:head($rule) ne $p:start-id) then $r
    else ruleset-fold(function($r,$rule){
      $r, $rule(function($c,$ws,$f) { dotted-rule($category,$c,$ws,$f) })
    },$r,fn:tail($rule))
  },(),$grammar)
  let $set := fn:fold-left(dotted-ruleset-put#2,dotted-ruleset(),$drs)
  let $states := dfa-build-state($grammar,states($grammar),$set,())
  return dfa-process-pending($grammar,$states)
};

declare %private function dfa-process-pending($grammar,$s)
{
  $s(function($states,$statemap,$pending,$names) {
    let $pe := states-next-pending-edge($s)
    return if(fn:empty($pe)) then $s else
      $pe(function($sid,$c) {
        let $state := array:get($states,$sid)
        return $state(function($drs,$nte,$te,$tre,$fns,$h) {
          let $newset := dotted-ruleset-fold(
            dfa-scan($grammar,?,$c,?),dotted-ruleset(),$drs)
          let $newstates := dfa-build-state($grammar,$s,$newset,$pe)
          return dfa-process-pending($grammar,$newstates)
        })
      })
  })
};

declare %private function dfa-build-state($grammar,$states,$set,$pe)
{
  let $set := dotted-ruleset-fold(dfa-predict-nullable($grammar,?,?),$set,$set)
  let $r := states-add-state($states,$grammar,state($grammar,$set),$pe)
  let $id := fn:head($r), $states := fn:tail($r)
  let $split-pe := pending-edge($id,$p:epsilon-category)
  let $split := dotted-ruleset-fold(dfa-predict($grammar,?,?),dotted-ruleset(),$set)
  let $split-empty := dotted-ruleset-fold(function($b,$dr) { fn:false() },fn:true(),$split)
  return if($split-empty) then $states else  
    fn:tail(states-add-state($states,$grammar,state($grammar,$split),$split-pe))
};

declare %private function dfa-scan($grammar,$set,$token,$dr)
{
  $dr(function($n,$cb,$ca,$ws,$h,$f) {
    if($ws and categories-eq($p:ws-category,$token)) then
      dotted-ruleset-put($set,$dr)
    else
    let $category := fn:head($ca)
    return
      if(fn:not(categories-eq($category,$token))) then $set
      else
        let $newdr := dotted-rule($n,($cb,fn:head($ca)),fn:tail($ca),$ws,$f)
        return dotted-ruleset-put($set,$newdr)
  })
};

declare %private function dfa-predict-nullable($grammar,$set,$dr)
{        
  fn:fold-left(
    function($set,$newdr) {
      if(dotted-ruleset-contains($set,$newdr)) then $set
      else dfa-predict-nullable($grammar,dotted-ruleset-put($set,$newdr),$newdr)
    },
    $set,
    $dr(function($n,$cb,$ca,$ws,$h,$f) {
      for $c1 in fn:head($ca)
      return $c1(
        (:nt:) function($h,$category) {
          if(category-nullable($grammar,$category)) then
            dotted-rule($n,($cb,fn:head($ca)),fn:tail($ca),$ws,$f) else ()
        },
        (:t:) function($h,$s) { () },
        (:tr:) function($h,$s,$e) { () }
      )
    })
  )
};

declare %private function dfa-predict($grammar,$set,$dr)
{
  fn:fold-left(
    function($set,$newdr) {
      if(dotted-ruleset-contains($set,$newdr)) then $set
      else dfa-predict-and-nullable($grammar,dotted-ruleset-put($set,$newdr),$newdr)
    },
    $set,
    $dr(function($n,$cb,$ca,$ws,$h,$f) {
      if(fn:not($ws)) then () else
        for $rule in grammar-get($grammar,$p:ws-state)
        return $rule(function($c,$ws,$f) { dotted-rule($p:ws-state,$c,$ws,$f) }),
      for $c1 in fn:head($ca)
      return $c1(
        (:nt:) function($h,$category) {
          for $rule in grammar-get($grammar,$category)
          return $rule(function($c,$ws,$f) { dotted-rule($category,$c,$ws,$f) })
        },
        (:t:) function($h,$s) { () },
        (:tr:) function($h,$s,$e) { () }
      )
    })
  )
};

declare %private function dfa-predict-and-nullable($grammar,$set,$dr)
{
  fn:fold-left(
    function($set,$newdr) {
      if(dotted-ruleset-contains($set,$newdr)) then $set
      else dfa-predict-and-nullable($grammar,dotted-ruleset-put($set,$newdr),$newdr)
    },
    $set,
    $dr(function($n,$cb,$ca,$ws,$h,$f) {
      if(fn:not($ws)) then () else
        for $rule in grammar-get($grammar,$p:ws-state)
        return $rule(function($c,$ws,$f) { dotted-rule($p:ws-state,$c,$ws,$f) }),
      for $c1 in fn:head($ca)
      return $c1(
        (:nt:) function($h,$category) {
          if(category-nullable($grammar,$category)) then
            dotted-rule($n,($cb,fn:head($ca)),fn:tail($ca),$ws,$f) else (),
          for $rule in grammar-get($grammar,$category)
          return $rule(function($c,$ws,$f) { dotted-rule($category,$c,$ws,$f) })
        },
        (:t:) function($h,$s) { () },
        (:tr:) function($h,$s,$e) { () }
      )
    })
  )
};

(: -------------------------------------------------------------------------- :)

(:
 : DFAChart = array(integer,RowSet)
 : RowSet = hamt(Row)
 : Row = State integer integer ParseTreeFunction*
 :)

declare %private function row($states,$sid,$parent,$bases)
{
  let $state := states-get($states,$sid)
  return function($f) { $f($state,$sid,$parent,$bases) }
};

declare %private function row-hash($row)
{
  $row(function($state,$sid,$parent,$bases) {
    hash(($sid,$parent))
  })
};

declare %private function row-eq($a,$b)
{
  $a(function($astate,$asid,$aparent,$abases) {
    $b(function($bstate,$bsid,$bparent,$bbases) {
      $asid eq $bsid and
      $aparent eq $bparent
    })
  })
};

declare %private function rowset() as item()
{
  hamt:create()
};

declare %private function rowset-put(
  $set as item(),
  $row
) as item()
{
  hamt:put(row-hash#1, row-eq#2, $set, $row)
};

declare %private function rowset-contains(
  $set as item(),
  $row
) as item()
{
  hamt:contains(row-hash#1, row-eq#2, $set, $row)
};

declare %private function rowset-fold(
  $f as function(item()*, item()) as item()*,
  $z as item()*,
  $set as item()
) as item()*
{
  hamt:fold($f,$z,$set)
};

declare %private function chart($states)
{
  let $rows := epsilon-expand($states,rowset(),0,row($states,0,0,()))
  return array:put(array:create(),0,$rows)
};

declare %private function chart-get($chart,$index)
{
  let $rows := array:get($chart,$index)
  return if(fn:empty($rows)) then () else
    rowset-fold(function($r,$row) { $r,$row },(),$rows)
};

declare function chart-as-string($chart)
{
  fn:string-join(
    for $index in (0 to (array:size($chart)-1))
    let $rows := chart-get($chart,$index)
    return (
      "========== Chart " || $index || " (" || fn:count($rows) || " rows) ==========",
      $rows ! .(function($state,$sid,$parent,$bases) {
        $index || ": State: " || $sid || ", Parent Chart:" || $parent || ", Bases: " || fn:count($bases),
        $state(function($drs,$nte,$te,$tre,$fns,$h) {
          dotted-ruleset-fold(function($s,$dr) {
            $s,
            $dr(function($n,$cb,$ca,$ws,$h,$f) {
              $index || ":   " || $n || " ::= " ||
              (if(fn:not($ws)) then "ws-explicit(" else "") ||
              fn:string-join($cb ! categories-as-string(.)," ") ||
              "." ||
              fn:string-join($ca ! categories-as-string(.)," ") ||
              (if(fn:not($ws)) then ")" else "")
            })
          },(),$drs),
          $fns ! ($index || ":     complete: " || fn:head(.()))
        })
      })
    )
  ,"&#10;")
};

declare %private function epsilon-expand($states,$rows,$index,$row)
{
  let $rows := rowset-put($rows,$row)
  return
  $row(function($state,$sid,$parent,$bases) {
    $state(function($drs,$nte,$te,$tre,$fns,$h) {
      let $id := array:get($nte,$p:epsilon-id)
      return if(fn:empty($id)) then $rows else
        let $row := row($states,$id,$index,())
        return if(rowset-contains($rows,$row)) then $rows else
          epsilon-expand($states,$rows,$index,$row)
    })
  })
};

declare function make-parser($grammar)
{
  make-parser-function($grammar,())
};

declare function make-parser($grammar,$options)
{
  if($options = "eval") then $p:eval(generate-xquery($grammar,("main-module",$options)))
  else make-parser-function($grammar,$options)
};

declare %private function make-parser-function($grammar,$options)
{
  let $_ := $p:log(grammar-as-string($grammar))
  let $grammar := $grammar($p:parse-default-actions)
  let $states := dfa($grammar)
  let $_ := $p:log(states-as-string($states))
  let $chart := chart($states)
  return function($s) {
    let $chart := parse($states,$chart,0,fn:string-to-codepoints($s))
    let $_ := $p:log(chart-as-string($chart))
    return find-result($states,$chart)
  }
};

declare %private function parse($states,$chart,$index,$tokens)
{
  let $rows := chart-get($chart,$index)
  return if(fn:empty($tokens) or fn:empty($rows)) then $chart else

  let $newindex := $index + 1
  let $token := fn:head($tokens)
  let $newrows := fn:fold-left(function($newrows,$row) {
    $row(function($state,$sid,$parent,$bases) {
      $state(function($drs,$nte,$te,$tre,$fns,$h) {
        let $newrows := fn:fold-left(function($newrows,$id) {
          let $row := row($states,$id,$parent,($bases,$token))
          return if(rowset-contains($newrows,$row)) then $newrows else
            epsilon-expand($states,$newrows,$newindex,$row)
        },$newrows,array:get($te,$token))
        return fn:fold-left(function($newrows,$e) {
          $e(function($s,$e,$id) {
            if($s gt $token or $token gt $e) then $newrows else
            let $row := row($states,$id,$parent,($bases,$token))
            return if(rowset-contains($newrows,$row)) then $newrows else
              epsilon-expand($states,$newrows,$newindex,$row)
          })
        },$newrows,$tre)
      })
    })
  },rowset(),$rows)
  let $newrows := rowset-fold(complete($states,$chart,?,$newindex,?),$newrows,$newrows)
  let $chart := array:put($chart,$newindex,$newrows)
  return parse($states,$chart,$newindex,fn:tail($tokens))
};

declare %private function complete($states,$chart,$rows,$index,$row)
{
  $row(function($state,$sid,$parent,$bases) {
    $state(function($drs,$nte,$te,$tre,$fns,$h) {
      fn:fold-left(function($rows,$c) { (: for each complete category :)

        let $c_ := $c()
        let $category := fn:head($c_)
        let $newbases := fn:tail($c_)($bases)
        return fn:fold-left(function($rows,$prow) { (: for each parent row :)

          $prow(function($pstate,$psid,$pparent,$pbases) {
            $pstate(function($pdrs,$pnte,$pte,$ptre,$pfns,$ph) {
              let $id := array:get($pnte,$category)
              return if(fn:empty($id)) then $rows else
                let $row := row($states,$id,$pparent,($pbases,$newbases))
                return if(rowset-contains($rows,$row)) then $rows else
                  let $rows := epsilon-expand($states,$rows,$index,$row)
                  return complete($states,$chart,$rows,$index,$row)
            })
          })
        },$rows,chart-get($chart,$parent))
      },$rows,$fns)
    })
  })
};

declare %private function find-result($states,$chart)
{
  let $rows := chart-get($chart,array:size($chart) - 1)
  return if(fn:empty($rows)) then
    parse-error(chart-get($chart,array:size($chart) - 2))
  else
  let $r :=
    fn:fold-left(function($r,$row) {
      if(fn:head($r)) then $r else
      $row(function($state,$sid,$parent,$bases) {
        $state(function($drs,$nte,$te,$tre,$fns,$h) {
          fn:fold-left(function($r,$c) {
            let $c_ := $c()
            let $category := fn:head($c_)
            let $fn := fn:tail($c_)
            return if(fn:head($r) or $category ne $p:start-id) then $r
              else if(fn:empty($fn)) then (fn:true(),$bases)
              else (fn:true(),$fn($bases))
          },fn:false(),$fns)
        })
      })
    },fn:false(),$rows)
  return if(fn:not(fn:head($r))) then
    parse-error($rows)
  else fn:tail($r)
};

declare %private function parse-error($rows)
{
  let $tokens := fn:distinct-values(fn:fold-left(function($tokens,$row) {
    $tokens,
    $row(function($state,$sid,$parent,$bases) {
      $state(function($drs,$nte,$te,$tre,$fns,$h) {
        array:fold(function($tokens,$k,$v) { $tokens,"'" || codepoint($k) || "'" },(),$te),
        for $e in $tre return $e(function($s,$e,$sid) {
          "[" || codepoint($s) || "-" || codepoint($e) || "]"
        })
      })
    })
  },(),$rows))
  let $err := if(fn:exists($tokens)) then fn:string-join($tokens,"', '")
    else "<EOF>"
  return fn:error(xs:QName("p:ERROR"),"Parse error, expecting: " || $err)
};

(: -------------------------------------------------------------------------- :)

declare function generate-xquery($grammar)
{
  generate-xquery($grammar,())
};

declare function generate-xquery($grammar,$options)
{
  let $namespace := $options[fn:starts-with(.,"namespace=")][1] !
    fn:substring-after(.,"namespace=")
  let $namespace := if(fn:exists($namespace) and $namespace ne "") then $namespace
    else "http://snelson.org.uk/functions/parser/generated"
  let $main-module := $options = "main-module"
  let $_ := $p:log(grammar-as-string($grammar))
  let $grammar := $grammar($p:generate-default-actions)
  let $states := dfa($grammar)
  let $_ := $p:log(states-as-string($states))
  let $moduleURI := fn:replace(try { fn:error() } catch * { $err:module },"^(.*/)[^/]*$","$1") ||
    (if($p:isMarkLogic) then "parser-runtime-ml.xq" else "parser-runtime.xq")
  return fn:string-join(

  $states(function($states,$statemap,$pending,$names) {
    'xquery version "3.0";',
    if($main-module) then (
      'declare namespace x = "' || $namespace || '";'
    ) else (
      'module namespace x = "' || $namespace || '";'
    ),
    "import module namespace p = 'http://snelson.org.uk/functions/parser-runtime' at '" || $moduleURI || "';",
    "declare %private function x:ref($s) { function() { $s } };",
    "declare %private variable $x:nt-names := (" ||
    fn:string-join(
      for $id in (0 to (array:size($names)-1))
      let $name := array:get($names,$id)
      return """" || $name || """"
    ,",") ||
    ");",

    "declare %private variable $x:nt-edges := (&#10;  " ||
    fn:string-join(
      for $id in (0 to (array:size($states)-1))
      let $state := array:get($states,$id)
      return $state(function($drs,$nte,$te,$tre,$fns,$h) {
        if(fn:empty(array:keys($nte))) then
          "function($c) { () }"
        else ("function($c) { switch($c)" ||
          fn:string-join(
            for $nt in array:keys($nte)
            return " case " || $nt || " return " || array:get($nte,$nt),
            "") ||
          " default return () }"
        )
      })
    ,",&#10;  ") ||
    ");",

    "declare %private variable $x:t-edges := (&#10;  " ||
    fn:string-join(
      for $id in (0 to (array:size($states)-1))
      let $state := array:get($states,$id)
      return $state(function($drs,$nte,$te,$tre,$fns,$h) {
        "function($c) {" || (
          if(fn:empty(array:keys($te))) then "" else (
            " switch($c)" ||
            fn:string-join(
              for $t in array:keys($te)
              return " case " || $t || " return (" ||
                fn:string-join(array:get($te,$t) ! fn:string(.), ",") || ")",
              "") ||
            " default return ()"
          )
        ) || (
          if(fn:empty($tre)) then "" else (
            (if(fn:empty(array:keys($te))) then "" else ", ") ||
            fn:string-join(
              for $e in $tre return $e(function($s,$e,$sid) {
                " if(" || $s || " le $c and $c le " || $e || ") then (" ||
                  fn:string-join($sid ! fn:string(.), ",") || ") else ()"
              }), ",")
          )
        ) || (
          if(fn:empty(array:keys($te)) and fn:empty($tre)) then " () }"
          else " }"
        )
      })
    ,",&#10;  ") ||
    ");",

    "declare %private variable $x:t-values := (&#10;  " ||
    fn:string-join(
      for $id in (0 to (array:size($states)-1))
      let $state := array:get($states,$id)
      return $state(function($drs,$nte,$te,$tre,$fns,$h) {
        "x:ref((" ||
        fn:string-join((
            array:keys($te) ! ('"' || codepoint-xq(.) || '"'),
            for $e in $tre return $e(function($s,$e,$sid) {
              '"[' || codepoint-xq($s) || "-" || codepoint-xq($e) || ']"'
            })
          ),",") ||
        "))"
      })
    ,",&#10;  ") ||
    ");",

    "declare %private variable $x:complete := (&#10;  " ||
    fn:string-join(
      for $id in (0 to (array:size($states)-1))
      let $state := array:get($states,$id)
      return $state(function($drs,$nte,$te,$tre,$fns,$h) {
        "x:ref((" ||
        fn:string-join(
          for $f in $fns
          let $c := $f()
          return (
            "&#10;    x:ref((" ||
            fn:string(fn:head($c)) ||
            ",function($ch) {&#10;" ||
            fn:tail($c) ||
            "&#10;    }))"
          )
        ,",") ||
        "))"
      })
    ,",&#10;  ") ||
    ");",
    if($main-module) then (
      "p:make-parser($x:nt-edges,$x:t-edges,$x:t-values,$x:complete,$x:nt-names)"
    ) else (
      "declare %private variable $x:parser :=",
      "  p:make-parser($x:nt-edges,$x:t-edges,$x:t-values,$x:complete,$x:nt-names);",
      "declare function x:parse($s) { $x:parser($s) };"
    )
  }),

  "&#10;")
};
