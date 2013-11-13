xquery version "1.0-ml";

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
import module namespace map = "http://snelson.org.uk/functions/hashmap" at "lib/hashmap.xq";
import module namespace array = "http://snelson.org.uk/functions/array" at "lib/array.xq";
import module namespace hamt = "http://snelson.org.uk/functions/hamt" at "lib/hamt.xq";

(:
 : Grammar = map(string,Rule)
 : Rule = (integer, RuleSet)
 : RuleSet = hamt(RuleRHS)
 : RuleRHS = Category* boolean ActionFunction
 : ActionFunction = function(item()*) as item()*
 : Category = NT integer string | T integer integer
 :)

declare variable $ws-state := "<ws>";
declare variable $ws-category := category-nt("<ws>");
declare variable $epsilon-state := "<epsilon>";
declare variable $epsilon-category := category-nt("<epsilon>");

declare variable $epsilon-id := 0;
declare variable $ws-id := 1;
declare variable $start-id := 2;

declare variable $ws-option := "ws-explicit";

declare %private function category-nt($n)
{
  let $hash := hash((fn:string-to-codepoints($n),0))
  return function($nt,$t) { $nt($hash,$n) }
};

declare %private function category-t($n)
{
  let $hash := hash((8945782,$n))
  return function($nt,$t) { $t($hash,$n) }
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
    (:t:) function($h,$s) { $h }
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
            (:t:) function($yh,$ys) { fn:false() }
          )
        },
        (:t:) function($xh,$xs) {
          $y(
            (:nt:) function($yh,$ys) { fn:false() },
            (:t:) function($yh,$ys) { $xs eq $ys }
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
  case 92 return "\\"
  default return fn:codepoints-to-string($c)
};

declare %private function category-as-string($c)
{
  $c((:nt:) function($h,$s) { $s },
     (:t:) function($h,$s) { "'" || codepoint($s) || "'" })
};

declare function grammar-as-string($grammar)
{
  fn:string-join(
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
            fn:string-join($c ! category-as-string(.)," ") ||
            (if(fn:not($ws)) then ")" else "")
          })
        },(),$ruleset),
      " | ")
    ),
  "&#10;")
};

declare %private function make-rules($n,$i,$c,$r,$ws,$f)
{
  if(fn:empty($r)) then ($i,function($g) { $g($n,$c,$ws,$f) })
  else fn:head($r)($n,$i,$c,fn:tail($r),$ws,$f)
};

declare %private function chain($i,$fns)
{
  if(fn:empty($fns)) then $i else
  let $r1 := fn:head($fns)($i)
  let $r2 := chain(fn:head($r1),fn:tail($fns))
  return (fn:head($r2),fn:tail($r1),fn:tail($r2))
};

declare function term($value)
{
  function($n,$i,$c,$r,$ws,$f) {
    let $n_ := $n || "_" || $i
    let $nt := non-term($n_)
    return (
      make-rules($n,$i+1,$c,($nt,$r),$ws,$f),
      fn:tail(make-rules($n_,1,fn:string-to-codepoints($value) ! category-t(.),(),fn:false(),
        fn:codepoints-to-string#1))
    )
  }
};

declare function term-($value)
{
  function($n,$i,$c,$r,$ws,$f) {
    let $n_ := $n || "_" || $i
    let $nt := non-term($n_)
    return (
      make-rules($n,$i+1,$c,($nt,$r),$ws,$f),
      fn:tail(make-rules($n_,1,fn:string-to-codepoints($value) ! category-t(.),(),fn:false(),
        discard#1))
    )
  }
};

declare function non-term($value)
{
  function($n,$i,$c,$r,$ws,$f) {
    make-rules($n,$i,($c,category-nt($value)),$r,$ws,$f)
  }
};

declare function optional($b)
{
  let $b_ := make-non-terms($b)
  return function($n,$i,$c,$r,$ws,$f) {
    chain($i,(
      make-rules($n,?,$c,$r,$ws,$f),
      make-rules($n,?,$c,($b_,$r),$ws,$f)
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
  return function($n,$i,$c,$r,$ws,$f) {
    let $n_ := $n || "_" || $i
    let $nt := non-term($n_)
    return (
      make-rules($n,$i+1,$c,($nt,$r),$ws,$f),
      fn:tail(chain(1,(
        make-rules($n_,?,(),$b_,$ws,()),
        make-rules($n_,?,(),($nt,$s_,$b_),$ws,())
      )))
    )
  }
};

declare function zero-or-more($b)
{
  let $b_ := make-non-terms($b)
  return function($n,$i,$c,$r,$ws,$f) {
    let $n_ := $n || "_" || $i
    let $nt := non-term($n_)
    return (
      make-rules($n,$i+1,$c,($nt,$r),$ws,$f),
      fn:tail(chain(1,(
        make-rules($n_,?,(),(),$ws,()),
        make-rules($n_,?,(),($nt,$b_),$ws,())
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
  return function($n,$i,$c,$r,$ws,$f) {
    chain($i,(
      make-rules($n,?,$c,($b1_,$r),$ws,$f),
      make-rules($n,?,$c,($b2_,$r),$ws,$f)
    ))
  }
};

declare function choice($b1,$b2,$b3)
{
  let $b1_ := make-non-terms($b1)
  let $b2_ := make-non-terms($b2)
  let $b3_ := make-non-terms($b3)
  return function($n,$i,$c,$r,$ws,$f) {
    chain($i,(
      make-rules($n,?,$c,($b1_,$r),$ws,$f),
      make-rules($n,?,$c,($b2_,$r),$ws,$f),
      make-rules($n,?,$c,($b3_,$r),$ws,$f)
    ))
  }
};

declare function choice($b1,$b2,$b3,$b4)
{
  let $b1_ := make-non-terms($b1)
  let $b2_ := make-non-terms($b2)
  let $b3_ := make-non-terms($b3)
  let $b4_ := make-non-terms($b4)
  return function($n,$i,$c,$r,$ws,$f) {
    chain($i,(
      make-rules($n,?,$c,($b1_,$r),$ws,$f),
      make-rules($n,?,$c,($b2_,$r),$ws,$f),
      make-rules($n,?,$c,($b3_,$r),$ws,$f),
      make-rules($n,?,$c,($b4_,$r),$ws,$f)
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
  return function($n,$i,$c,$r,$ws,$f) {
    chain($i,(
      make-rules($n,?,$c,($b1_,$r),$ws,$f),
      make-rules($n,?,$c,($b2_,$r),$ws,$f),
      make-rules($n,?,$c,($b3_,$r),$ws,$f),
      make-rules($n,?,$c,($b4_,$r),$ws,$f),
      make-rules($n,?,$c,($b5_,$r),$ws,$f)
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
  return function($n,$i,$c,$r,$ws,$f) {
    chain($i,(
      make-rules($n,?,$c,($b1_,$r),$ws,$f),
      make-rules($n,?,$c,($b2_,$r),$ws,$f),
      make-rules($n,?,$c,($b3_,$r),$ws,$f),
      make-rules($n,?,$c,($b4_,$r),$ws,$f),
      make-rules($n,?,$c,($b5_,$r),$ws,$f),
      make-rules($n,?,$c,($b6_,$r),$ws,$f)
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

declare function rule($n,$categories,$options)
{
  let $valid := try { xs:NCName($n) } catch * { () }
  return if(try { fn:empty(xs:NCName($n)) } catch * { fn:true() }) then
    fn:error(xs:QName("p:BADNAME"),"Invalid rule name: " || $n)
  else
    rule($n,$categories,$options,tree($n,?))
};

declare function rule-($n,$categories,$options)
{
  rule($n,$categories,$options,children#1)
};

declare function rule($n,$categories,$options,$f)
{
  let $ws := fn:not($options = $p:ws-option)
  return fn:tail(make-rules($n,1,(),make-non-terms($categories),$ws,$f))
};

declare function token($n,$categories)
{
  rule($n,$categories,$p:ws-option,fn:string-join#1)
};

declare function token-($n,$categories)
{
  rule($n,$categories,$p:ws-option,discard#1)
};

declare function ws($n,$categories)
{
  ws($n,$categories,function($ch) { () })
};

declare function ws($n,$categories,$f)
{
  rule($n,$categories,$p:ws-option,$f),
  rule($p:ws-state,$n,$p:ws-option,())
};

declare function grammar($rules)
{
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
      (:t:) function($h,$s) { fn:false() })) and
    (every $rc in $rule(function($c,$ws,$f) { $c }) satisfies $rc(
      (:nt:) function($h,$s) { category-nullable($grammar,$s,($searched,$category)) },
      (:t:) function($h,$s) { fn:false() }))
};

(: -------------------------------------------------------------------------- :)
(: Built-In Actions :)

declare function tree($n,$ch)
{
  function() {
    element { $n } {
      $ch ! (
        typeswitch(.)
        case xs:string return text { . }
        default return .()
      )
    }
  }
};

declare function children($ch)
{
  function() {
    $ch ! (
      typeswitch(.)
      case xs:string return text { . }
      default return .()
    )
  }
};

declare function discard($ch)
{
  function() { () }
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
 : States = array(integer,State) array(state-hash(State),integer) hamt(PendingEdge)
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
        $state(function($drs,$nte,$te,$fns,$h) {
          "State " || $id || " (" || $h || ")",
          dotted-ruleset-fold(function($s,$dr) {
            $s,
            $dr(function($n,$cb,$ca,$ws,$h,$f) {
              "  " || $n || " ::= " ||
              (if(fn:not($ws)) then "ws-explicit(" else "") ||
              fn:string-join($cb ! category-as-string(.)," ") ||
              "." ||
              fn:string-join($ca ! category-as-string(.)," ") ||
              (if(fn:not($ws)) then ")" else "")
            })
          },(),$drs),
          array:fold(function($s,$nt,$sid) {
            $s, "    edge: " || $nt || " -> " || $sid
          },(),$nte),
          array:fold(function($s,$t,$sid) {
            $s, "    edge: '" || codepoint($t) || "' -> " || $sid
          },(),$te),
          $fns ! ("    complete: " || fn:head(.()))
        }),
      hamt:fold(function($s,$pe) {
        $s,$pe(function($s,$c) {
          "pending edge state: " || $s || ", category: " || category-as-string($c)
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
    $state(function($drs,$nte,$te,$fns,$h) {
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
  return function($f) { $f($drs,$nte,$te,$fns,$h) }
};

declare %private function state-hash($a as item()) as xs:integer { $a(function($drs,$nte,$te,$fns,$h) { $h }) };

declare %private function state-eq($a as item(), $b as item()) as xs:boolean
{
  $a(function($drs1,$nte1,$te1,$fns1,$h1) {
    $b(function($drs2,$nte2,$te2,$fns2,$h2) {
      $h1 eq $h2
    })
  })
};

declare %private function state-add-edge($state,$grammar,$c,$id)
{
  $state(function($drs,$nte,$te,$fns,$h) {
    $c(
      (:nt:) function($h,$category) {
        let $cid := grammar-get-id($grammar,$category)
        let $nte := array:put($nte,$cid,$id)
        return function($f) { $f($drs,$nte,$te,$fns,$h) }
      },
      (:t:) function($h,$s) {
        let $te := array:put($te,$s,$id)
        return function($f) { $f($drs,$nte,$te,$fns,$h) }
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
        return $state(function($drs,$nte,$te,$fns,$h) {
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
        (:t:) function($h,$s) { () })
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
        (:t:) function($h,$s) { () })
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
        (:t:) function($h,$s) { () })
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
        $state(function($drs,$nte,$te,$fns,$h) {
          dotted-ruleset-fold(function($s,$dr) {
            $s,
            $dr(function($n,$cb,$ca,$ws,$h,$f) {
              $index || ":   " || $n || " ::= " ||
              (if(fn:not($ws)) then "ws-explicit(" else "") ||
              fn:string-join($cb ! category-as-string(.)," ") ||
              "." ||
              fn:string-join($ca ! category-as-string(.)," ") ||
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
    $state(function($drs,$nte,$te,$fns,$h) {
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
  let $_ := xdmp:log(grammar-as-string($grammar))
  let $states := dfa($grammar)
  let $_ := xdmp:log(states-as-string($states))
  let $chart := chart($states)
  return function($s) {
    let $chart := parse($states,$chart,0,fn:string-to-codepoints($s))
    let $_ := xdmp:log(chart-as-string($chart))
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
      $state(function($drs,$nte,$te,$fns,$h) {
        let $id := array:get($te,$token)
        return if(fn:empty($id)) then $newrows else
          let $row := row($states,$id,$parent,($bases,$token))
          return if(rowset-contains($newrows,$row)) then $newrows else
            epsilon-expand($states,$newrows,$newindex,$row)
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
    $state(function($drs,$nte,$te,$fns,$h) {
      fn:fold-left(function($rows,$c) { (: for each complete category :)

        let $c_ := $c()
        let $category := fn:head($c_)
        let $fn := fn:tail($c_)
        let $newbases := if(fn:empty($fn)) then $bases else $fn($bases)
        return fn:fold-left(function($rows,$prow) { (: for each parent row :)

          $prow(function($pstate,$psid,$pparent,$pbases) {
            $pstate(function($pdrs,$pnte,$pte,$pfns,$ph) {
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
        $state(function($drs,$nte,$te,$fns,$h) {
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
      $state(function($drs,$nte,$te,$fns,$h) {
        array:fold(function($tokens,$k,$v) { $tokens,"'" || codepoint($k) || "'" },(),$te)
      })
    })
  },(),$rows))
  let $err := if(fn:exists($tokens)) then fn:string-join($tokens,"', '")
    else "<EOF>"
  return fn:error(xs:QName("p:ERROR"),"Parse error, expecting: " || $err)
};
