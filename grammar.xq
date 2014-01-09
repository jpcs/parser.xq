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

module namespace gr = "http://snelson.org.uk/functions/grammar";
declare default function namespace "http://snelson.org.uk/functions/grammar";
import module namespace map = "http://snelson.org.uk/functions/hashmap" at "lib/hashmap.xq";
import module namespace array = "http://snelson.org.uk/functions/array" at "lib/array.xq";
import module namespace hamt = "http://snelson.org.uk/functions/hamt" at "lib/hamt.xq";

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

declare function hash($a as xs:integer*) as xs:integer
{
  fn:fold-left(hash-fuse#2,2489012344,$a)
};

declare function categories-hash($a as item()*) as xs:integer
{
  hash($a ! .(
    (:nt:) function($h,$s) { $h },
    (:t:) function($h,$s) { $h },
    (:tr:) function($h,$s,$e) { $h }
  ))
};

declare function categories-eq($a as item()*, $b as item()*) as xs:boolean
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

declare function ruleset-fold(
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

declare function categories-as-string($cs)
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

declare %private variable $dummy-actions := (
  "",
  "",
  "",
  "",
  function($n) { "" },
  function($n) { "" }
);

declare function grammar-as-string($grammar)
{
  let $grammar := $grammar($gr:dummy-actions)
  return fn:string-join(
    for $r in map:fold(function($z,$n,$rule) { $z,function() { $n,$rule } },(),$grammar)
    let $r_ := $r()
    let $n := fn:head($r_)
    let $r_ := fn:tail($r_)
    let $id := fn:head($r_)
    let $ruleset := fn:tail($r_)
    where $id ne $gr:epsilon-id
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
  let $ws := fn:not($options = $gr:ws-option)
  return function($df) {
    fn:tail(make-rules($n,1,(),make-non-terms($categories),$ws,$df[5]($n),$df))
  }
};

declare function rule-($n,$categories,$options)
{
  let $ws := fn:not($options = $gr:ws-option)
  return function($df) {
    fn:tail(make-rules($n,1,(),make-non-terms($categories),$ws,$df[4],$df))
  }
};

declare function rule-attr($n,$categories,$options)
{
  let $ws := fn:not($options = $gr:ws-option)
  return function($df) {
    fn:tail(make-rules($n,1,(),make-non-terms($categories),$ws,$df[6]($n),$df))
  }
};

declare function rule($n,$categories,$options,$f)
{
  let $ws := fn:not($options = $gr:ws-option)
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
    rule($n,$categories,$gr:ws-option,$df[1])($df),
    rule($gr:ws-state,$n,$gr:ws-option,$df[1])($df)
  }
};

declare function ws($n,$categories,$f)
{
  function($df) {
    rule($n,$categories,$gr:ws-option,$f)($df),
    rule($gr:ws-state,$n,$gr:ws-option,$df[1])($df)
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
          if($category eq $gr:ws-state) then $gr:ws-id
          else if(fn:exists($rule)) then fn:head($rule)
          else (map:count($map) + $gr:start-id)
        let $set := if(fn:exists($rule)) then fn:tail($rule) else ruleset()
        return map:put($map,$category,($id,ruleset-put($set,rulerhs($categories,$ws,$f))))
      })
    },
    map:create(),
    $rules
  )
  return map:put($map,$gr:epsilon-state,($gr:epsilon-id))
};

declare function grammar-get($grammar,$category)
{
  let $rule := map:get($grammar,$category)
  where fn:exists($rule)
  return ruleset-fold(function($s,$c){ $s,$c },(),fn:tail($rule))
};

declare function grammar-get-id($grammar,$category)
{
  let $rule := map:get($grammar,$category)
  where fn:exists($rule)
  return fn:head($rule)
};

declare function category-nullable($grammar,$category)
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
