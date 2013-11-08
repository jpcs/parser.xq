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
 : Grammar = map(string,RuleSet)
 : RuleSet = hamt(RuleRHS)
 : RuleRHS = Category* boolean
 : Category = NT integer string | T integer integer
 :)

declare variable $start-state := "<start>";
declare variable $ws-state := "<ws>";
declare variable $ws-category := category-nt("<ws>");
declare variable $epsilon-state := "<epsilon>";
declare variable $epsilon-category := category-nt("<epsilon>");

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

declare %private function rulerhs($categories,$ws) { function($f) { $f($categories,$ws) } };

declare %private function rulerhs-hash($a as item()) as xs:integer
{
  $a(function($c,$ws) {
    hash((categories-hash($c),xs:integer($ws)))
  })
};

declare %private function rulerhs-eq($a as item(), $b as item()) as xs:boolean
{
  $a(function($ac,$aws) {
    $b(function($bc,$bws) {
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
  fn:string-join(map:fold(
    function($z,$n,$set) {
      $z,
      $n || " ::= " ||
      fn:string-join(
        ruleset-fold(
          function($s,$rule) {
            $s,
            $rule(function($c,$ws) {
              (if(fn:not($ws)) then "ws_explicit(" else "") ||
              fn:string-join($c ! category-as-string(.)," ") ||
              (if(fn:not($ws)) then ")" else "")
            })
          },(),$set)," | ")
    },(),$grammar),"&#10;")
};

declare %private function make-rules($n,$i,$c,$r,$ws)
{
  if(fn:empty($r)) then ($i,function($f) { $f($n,$c,$ws) })
  else fn:head($r)($n,$i,$c,fn:tail($r),$ws)
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
  function($n,$i,$c,$r,$ws) {
    if((fn:empty($c) and fn:empty($r)) or fn:not($ws)) then
      make-rules($n,$i,($c,fn:string-to-codepoints($value) ! category-t(.)),$r,fn:false())
    else
      let $n_ := $n || "_" || $i
      let $nt := non-term($n_)
      return (
        make-rules($n,$i+1,$c,($nt,$r),$ws),
        fn:tail(make-rules($n_,1,fn:string-to-codepoints($value) ! category-t(.),(),fn:false()))
      )
  }
};

declare function non-term($value)
{
  function($n,$i,$c,$r,$ws) {
    make-rules($n,$i,($c, category-nt($value)),$r,$ws)
  }
};

declare function optional($b)
{
  let $b_ := make-non-terms($b)
  return function($n,$i,$c,$r,$ws) {
    chain($i,(
      make-rules($n,?,$c,$r,$ws),
      make-rules($n,?,$c,($b_,$r),$ws)
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
  return function($n,$i,$c,$r,$ws) {
    if(fn:empty($r)) then
      chain($i,(
        make-rules($n,?,$c,$b_,$ws),
        make-rules($n,?,(),(non-term($n),$s_,$b_),$ws)
      ))
    else
      let $n_ := $n || "_" || $i
      let $nt := non-term($n_)
      return (
        make-rules($n,$i+1,$c,($nt,$r),$ws),
        fn:tail(chain(1,(
          make-rules($n_,?,(),$b_,$ws),
          make-rules($n_,?,(),($nt,$s_,$b_),$ws)
        )))
      )
  }
};

declare function zero-or-more($b)
{
  let $b_ := make-non-terms($b)
  return function($n,$i,$c,$r,$ws) {
    if(fn:empty($r)) then
      chain($i,(
        make-rules($n,?,$c,(),$ws),
        make-rules($n,?,(),(non-term($n),$b_),$ws)
      ))
    else
      let $n_ := $n || "_" || $i
      let $nt := non-term($n_)
      return (
        make-rules($n,$i+1,$c,($nt,$r),$ws),
        fn:tail(chain(1,(
          make-rules($n_,?,(),(),$ws),
          make-rules($n_,?,(),($nt,$b_),$ws)
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
  return function($n,$i,$c,$r,$ws) {
    chain($i,(
      make-rules($n,?,$c,($b1_,$r),$ws),
      make-rules($n,?,$c,($b2_,$r),$ws)
    ))
  }
};

declare function choice($b1,$b2,$b3)
{
  let $b1_ := make-non-terms($b1)
  let $b2_ := make-non-terms($b2)
  let $b3_ := make-non-terms($b3)
  return function($n,$i,$c,$r,$ws) {
    chain($i,(
      make-rules($n,?,$c,($b1_,$r),$ws),
      make-rules($n,?,$c,($b2_,$r),$ws),
      make-rules($n,?,$c,($b3_,$r),$ws)
    ))
  }
};

declare function choice($b1,$b2,$b3,$b4)
{
  let $b1_ := make-non-terms($b1)
  let $b2_ := make-non-terms($b2)
  let $b3_ := make-non-terms($b3)
  let $b4_ := make-non-terms($b4)
  return function($n,$i,$c,$r,$ws) {
    chain($i,(
      make-rules($n,?,$c,($b1_,$r),$ws),
      make-rules($n,?,$c,($b2_,$r),$ws),
      make-rules($n,?,$c,($b3_,$r),$ws),
      make-rules($n,?,$c,($b4_,$r),$ws)
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
  return function($n,$i,$c,$r,$ws) {
    chain($i,(
      make-rules($n,?,$c,($b1_,$r),$ws),
      make-rules($n,?,$c,($b2_,$r),$ws),
      make-rules($n,?,$c,($b3_,$r),$ws),
      make-rules($n,?,$c,($b4_,$r),$ws),
      make-rules($n,?,$c,($b5_,$r),$ws)
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
  return function($n,$i,$c,$r,$ws) {
    chain($i,(
      make-rules($n,?,$c,($b1_,$r),$ws),
      make-rules($n,?,$c,($b2_,$r),$ws),
      make-rules($n,?,$c,($b3_,$r),$ws),
      make-rules($n,?,$c,($b4_,$r),$ws),
      make-rules($n,?,$c,($b5_,$r),$ws),
      make-rules($n,?,$c,($b6_,$r),$ws)
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
  rule($n,$categories,fn:true())
};

declare function rule($n,$categories,$ws)
{
  fn:tail(make-rules($n,1,(),make-non-terms($categories),$ws))
};

declare function grammar($rules)
{
  fn:fold-left(
    function($map,$rule) {
      $rule(function($category,$categories,$ws) {
        let $set := map:get($map,$category)
        let $set := if(fn:exists($set)) then $set else ruleset()
        return map:put($map,$category,ruleset-put($set,rulerhs($categories,$ws)))
      })
    },
    map:create(),
    $rules
  )
};

declare %private function grammar-get($grammar,$category)
{
  let $set := map:get($grammar,$category)
  where fn:exists($set)
  return ruleset-fold(function($s,$c){ $s,$c },(),$set)
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
    (every $rc in $rule(function($c,$ws) { $c }) satisfies $rc(
      (:nt:) function($h,$s) { fn:true() },
      (:t:) function($h,$s) { fn:false() })) and
    (every $rc in $rule(function($c,$ws) { $c }) satisfies $rc(
      (:nt:) function($h,$s) { category-nullable($grammar,$s,($searched,$category)) },
      (:t:) function($h,$s) { fn:false() }))
};

(: -------------------------------------------------------------------------- :)

(:
 : DottedRuleSet = hamt(DottedRule)
 : DottedRule = string Category* Category* boolean integer
 :)

declare %private function dotted-rule($n,$c,$ws)
{
  dotted-rule($n,(),$c,$ws)
};

declare %private function dotted-rule($n,$cb,$ca,$ws)
{
  let $h := hash((
      fn:string-to-codepoints($n),
      categories-hash($ca),
      xs:integer($ws)
    )) 
  return function($f) { $f($n,$cb,$ca,$ws,$h) }
};

declare %private function dotted-rule-hash($a as item()) as xs:integer { $a(function($n,$cb,$ca,$ws,$h) { $h }) };

declare %private function dotted-rule-eq($a as item(), $b as item()) as xs:boolean
{
  $a(function($n1,$cb1,$ca1,$ws1,$h1) {
    $b(function($n2,$cb2,$ca2,$ws2,$h2) {
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
 : State = DottedRuleSet map(string,integer) array(integer,integer) hamt(Category) integer
 :)

declare %private function states-as-string($s)
{
  $s(function($states,$statemap,$pending) {
    fn:string-join((
      for $id in (0 to (array:size($states)-1))
      let $state := array:get($states,$id)
      return
        $state(function($drs,$nte,$te,$cs,$h) {
          "State " || $id || " (" || $h || ")",
          dotted-ruleset-fold(function($s,$dr) {
            $s,
            $dr(function($n,$cb,$ca,$ws,$h) {
              "  " || $n || " ::= " ||
              (if(fn:not($ws)) then "ws_explicit(" else "") ||
              fn:string-join($cb ! category-as-string(.)," ") ||
              "." ||
              fn:string-join($ca ! category-as-string(.)," ") ||
              (if(fn:not($ws)) then ")" else "")
            })
          },(),$drs),
          map:fold(function($s,$nt,$sid) {
            $s, "    edge: " || $nt || " -> " || $sid
          },(),$nte),
          array:fold(function($s,$t,$sid) {
            $s, "    edge: '" || codepoint($t) || "' -> " || $sid
          },(),$te),
          map:fold(function($s,$c,$_) {
            $s, "    complete: " || $c
          },(),$cs)
        }),
      hamt:fold(function($s,$pe) {
        $s,$pe(function($s,$c) {
          "pending edge state: " || $s || ", category: " || category-as-string($c)
        })
      },(),$pending)
    ),"&#10;")
  })
};

declare %private function states()
{
  let $states := array:create()
  let $statemap := array:create()
  let $pending := hamt:create()
  return function($f) { $f($states,$statemap,$pending) }
};

declare %private function states-get($s,$id)
{
  $s(function($states,$statemap,$pending) {
    array:get($states,$id)
  })
};

declare %private function states-add-state($s,$grammar,$state,$pe)
{
  $s(function($states,$statemap,$pending) {
    $state(function($drs,$nte,$te,$cs,$h) {
      let $id := array:get($statemap,$h)
      return if(fn:exists($id)) then
        let $states_ := if(fn:empty($pe)) then $states else
          statesarray-add-edge($states,$pe,$id)
        let $pending_ := if(fn:empty($pe)) then $pending else
          hamt:delete(pending-edge-hash#1,pending-edge-eq#2,$pending,$pe)
        return ($id,function($f) { $f($states_,$statemap,$pending_) })
      else 
        let $id := array:size($states)
        let $states_ := array:put($states,$id,$state)
        let $statemap_ := array:put($statemap,$h,$id)
        let $states_ := if(fn:empty($pe)) then $states_ else
          statesarray-add-edge($states_,$pe,$id)
        let $pending_ := dotted-ruleset-fold(function($p,$dr) {
            $dr(function($n,$cb,$ca,$ws,$h) {
              if(fn:empty($ca)) then $p else
              hamt:put(pending-edge-hash#1,pending-edge-eq#2,$p,pending-edge($id,fn:head($ca)))
            })
          },$pending,$drs)
        let $ws := fn:exists(grammar-get($grammar,$p:ws-state)) and
          dotted-ruleset-fold(function($b,$dr) {
            $b or $dr(function($n,$cb,$ca,$ws,$h) { $ws }) },fn:false(),$drs)
        let $pending_ := if(fn:not($ws)) then $pending_ else
          hamt:put(pending-edge-hash#1,pending-edge-eq#2,$pending_,
            pending-edge($id,$p:ws-category))
        let $pending_ := if(fn:empty($pe)) then $pending_ else
          hamt:delete(pending-edge-hash#1,pending-edge-eq#2,$pending_,$pe)
        return ($id,function($f) { $f($states_,$statemap_,$pending_) })
    })
  })
};

declare %private function statesarray-add-edge($states,$pe,$id)
{
  $pe(function($s,$c) {
    array:put($states,$s,state-add-edge(array:get($states,$s),$c,$id))
  })
};

declare %private function states-next-pending-edge($s)
{
  $s(function($states,$statemap,$pending) {
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

declare %private function state($drs)
{
  let $nte := map:create()
  let $te := array:create()
  let $cs := dotted-ruleset-fold(function($cs,$dr) {
      $dr(function($n,$cb,$ca,$ws,$h) {
        if(fn:exists($ca)) then $cs else map:put($cs,$n,())
      })
    },map:create(),$drs)
  let $h := dotted-ruleset-hash($drs)
  return function($f) { $f($drs,$nte,$te,$cs,$h) }
};

declare %private function state-hash($a as item()) as xs:integer { $a(function($drs,$nte,$te,$cs,$h) { $h }) };

declare %private function state-eq($a as item(), $b as item()) as xs:boolean
{
  $a(function($drs1,$nte1,$te1,$cs1,$h1) {
    $b(function($drs2,$nte2,$te2,$cs2,$h2) {
      $h1 eq $h2
    })
  })
};

declare %private function state-add-edge($state,$c,$id)
{
  $state(function($drs,$nte,$te,$cs,$h) {
    $c(
      (:nt:) function($h,$category) {
        let $nte := map:put($nte,$category,$id)
        return function($f) { $f($drs,$nte,$te,$cs,$h) }
      },
      (:t:) function($h,$s) {
        let $te := array:put($te,$s,$id)
        return function($f) { $f($drs,$nte,$te,$cs,$h) }
      }
    )
  })
};

(: -------------------------------------------------------------------------- :)

declare %private function dfa($grammar,$start)
{
  let $dr := dotted-rule($p:start-state,category-nt($start),fn:false())
  let $set := dotted-ruleset-put(dotted-ruleset(),$dr)
  let $states := dfa-build-state($grammar,states(),$set,())
  return dfa-process-pending($grammar,$states)
};

declare %private function dfa-process-pending($grammar,$s)
{
  $s(function($states,$statemap,$pending) {
    let $pe := states-next-pending-edge($s)
    return if(fn:empty($pe)) then $s else
      $pe(function($sid,$c) {
        let $state := array:get($states,$sid)
        return $state(function($drs,$nte,$te,$cs,$h) {
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
  let $r := states-add-state($states,$grammar,state($set),$pe)
  let $id := fn:head($r), $states := fn:tail($r)
  let $split-pe := pending-edge($id,$p:epsilon-category)
  let $split := dotted-ruleset-fold(dfa-predict($grammar,?,?),dotted-ruleset(),$set)
  let $split-empty := dotted-ruleset-fold(function($b,$dr) { fn:false() },fn:true(),$split)
  return if($split-empty) then $states else  
    fn:tail(states-add-state($states,$grammar,state($split),$split-pe))
};

declare %private function dfa-scan($grammar,$set,$token,$dr)
{
  $dr(function($n,$cb,$ca,$ws,$h) {
    if($ws and categories-eq($p:ws-category,$token)) then
      dotted-ruleset-put($set,$dr)
    else
    let $category := fn:head($ca)
    return
      if(fn:not(categories-eq($category,$token))) then $set
      else
        let $newdr := dotted-rule($n,($cb,fn:head($ca)),fn:tail($ca),$ws)
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
    $dr(function($n,$cb,$ca,$ws,$h) {
      for $c1 in fn:head($ca)
      return $c1(
        (:nt:) function($h,$category) {
          if(category-nullable($grammar,$category)) then
            dotted-rule($n,($cb,fn:head($ca)),fn:tail($ca),$ws) else ()
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
      else
        dfa-predict-nullable($grammar,
          dfa-predict($grammar,dotted-ruleset-put($set,$newdr),$newdr),$newdr)
    },
    $set,
    $dr(function($n,$cb,$ca,$ws,$h) {
      if(fn:not($ws)) then () else
        for $rule in grammar-get($grammar,$p:ws-state)
        return $rule(function($c,$ws) { dotted-rule($p:ws-state,$c,$ws) }),
      for $c1 in fn:head($ca)
      return $c1(
        (:nt:) function($h,$category) {
          for $rule in grammar-get($grammar,$category)
          return $rule(function($c,$ws) { dotted-rule($category,$c,$ws) })
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
        $state(function($drs,$nte,$te,$cs,$h) {
          dotted-ruleset-fold(function($s,$dr) {
            $s,
            $dr(function($n,$cb,$ca,$ws,$h) {
              $index || ":   " || $n || " ::= " ||
              (if(fn:not($ws)) then "ws_explicit(" else "") ||
              fn:string-join($cb ! category-as-string(.)," ") ||
              "." ||
              fn:string-join($ca ! category-as-string(.)," ") ||
              (if(fn:not($ws)) then ")" else "")
            })
          },(),$drs),
          map:fold(function($s,$c,$_) {
            $s, $index || ":     complete: " || $c
          },(),$cs)
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
    $state(function($drs,$nte,$te,$cs,$h) {
      let $id := map:get($nte,$p:epsilon-state)
      return if(fn:empty($id)) then $rows else
        let $row := row($states,$id,$index,())
        return if(rowset-contains($rows,$row)) then $rows else
          epsilon-expand($states,$rows,$index,$row)
    })
  })
};

declare function make-parser($grammar,$start)
{
  let $states := dfa($grammar,$start)
  let $chart := chart($states)
  return function($s) {
    let $chart := parse($states,$chart,0,fn:string-to-codepoints($s))
    return parse-tree($chart)
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
      $state(function($drs,$nte,$te,$cs,$h) {
        let $id := array:get($te,$token)
        return if(fn:empty($id)) then $newrows else
          let $fn := function() { text { fn:codepoints-to-string($token) } }
          let $row := row($states,$id,$parent,($bases,$fn))
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
    $state(function($drs,$nte,$te,$cs,$h) {
      map:fold(function($rows,$category,$v) {
        fn:fold-left(function($rows,$prow) {
          $prow(function($pstate,$psid,$pparent,$pbases) {
            $pstate(function($pdrs,$pnte,$pte,$pcs,$ph) {
              let $id := map:get($pnte,$category)
              return if(fn:empty($id)) then $rows else
                let $fn := if(fn:starts-with($category,"<")) then $bases
                  else function() { element { $category } { $bases ! .() } }
                let $row := row($states,$id,$pparent,($pbases,$fn))
                return if(rowset-contains($rows,$row)) then $rows else
                  let $rows := epsilon-expand($states,$rows,$index,$row)
                  return complete($states,$chart,$rows,$index,$row)
            })
          })
        },$rows,chart-get($chart,$parent))
      },$rows,$cs)
    })
  })
};

declare %private function parse-tree($chart)
{
  for $row in chart-get($chart,array:size($chart) - 1)
  return $row(function($state,$sid,$parent,$bases) {
    $state(function($drs,$nte,$te,$cs,$h) {
      if(map:contains($cs,$p:start-state)) then
        document { $bases ! .() }
      else ()
    })
  })
};
