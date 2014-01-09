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

module namespace p = "http://snelson.org.uk/functions/parser-runtime";
declare default function namespace "http://snelson.org.uk/functions/parser-runtime";
import module namespace map = "http://snelson.org.uk/functions/hashmap" at "lib/hashmap.xq";
import module namespace array = "http://snelson.org.uk/functions/array" at "lib/array.xq";
import module namespace hamt = "http://snelson.org.uk/functions/hamt" at "lib/hamt.xq";

declare variable $epsilon-id := 0;
declare variable $ws-id := 1;
declare variable $start-id := 2;

(: -------------------------------------------------------------------------- :)

declare %private function hash-fuse($z,$v) as xs:integer
{
  xs:integer((($z * 5) + $v) mod 4294967296)
};

declare %private function hash($a as xs:integer*) as xs:integer
{
  fn:fold-left(hash-fuse#2,2489012344,$a)
};

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

(: -------------------------------------------------------------------------- :)

(:
 : DFAChart = array(integer,RowSet)
 : RowSet = hamt(Row)
 : Row = integer* integer* (integer,ActionFunction)* integer integer item()*
 : States = (integer*)* (integer*)* ((integer,ActionFunction)*)* string*
 :)

declare %private function states($nt-edges,$t-edges,$t-values,$complete,$nt-names)
{
  function($f) { $f($nt-edges,$t-edges,$t-values,$complete,$nt-names) }
};

declare %private function row($states,$sid,$parent,$bases)
{
  $states(function($nt-edges,$t-edges,$t-values,$complete,$nt-names) {
    let $i := $sid + 1
    let $nte := $nt-edges[$i]
    let $te := $t-edges[$i]
    let $tv := $t-values[$i]()
    let $c := $complete[$i]()
    return function($f) { $f($nte,$te,$tv,$c,$sid,$parent,$bases) }
  })
};

declare %private function row-hash($row)
{
  $row(function($nte,$te,$tv,$c,$sid,$parent,$bases) {
    hash(($sid,$parent))
  })
};

declare %private function row-eq($a,$b)
{
  $a(function($ante,$ate,$atv,$ac,$asid,$aparent,$abases) {
    $b(function($bnte,$bte,$btv,$bc,$bsid,$bparent,$bbases) {
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
      $rows ! .(function($nte,$te,$tv,$c,$sid,$parent,$bases) {
        $index || ": State: " || $sid || ", Parent Chart:" || $parent || ", Bases: " || fn:count($bases),
        $index || ":   complete: (" || fn:string-join($c ! fn:string(fn:head(.())),",") || ")"
      })
    )
  ,"&#10;")
};

declare %private function epsilon-expand($states,$rows,$index,$row)
{
  $row(function($nte,$te,$tv,$c,$sid,$parent,$bases) {
    let $rows := rowset-put($rows,$row)
    let $id := $nte($p:epsilon-id)
    return if(fn:empty($id)) then $rows else
      let $row := row($states,$id,$index,())
      return if(rowset-contains($rows,$row)) then $rows else
        epsilon-expand($states,$rows,$index,$row)
  })
};

declare function make-parser($nt-edges,$t-edges,$t-values,$complete,$nt-names)
{
  let $states := states($nt-edges,$t-edges,$t-values,$complete,$nt-names)
  let $chart := chart($states)
  return function($s) {
    let $tokens := fn:string-to-codepoints($s)
    let $chart := parse($states,$chart,0,$tokens)
    return find-result($tokens,$chart)
  }
};

declare %private function parse($states,$chart,$index,$tokens)
{
  let $rows := chart-get($chart,$index)
  return if(fn:empty($tokens) or fn:empty($rows)) then $chart else

  let $newindex := $index + 1
  let $token := fn:head($tokens)
  let $newrows := fn:fold-left(function($newrows,$row) {
    $row(function($nte,$te,$tv,$c,$sid,$parent,$bases) {
      fn:fold-left(function($newrows,$id) {
        let $row := row($states,$id,$parent,($bases,$token))
        return if(rowset-contains($newrows,$row)) then $newrows else
          epsilon-expand($states,$newrows,$newindex,$row)
      },$newrows,$te($token))
    })
  },rowset(),$rows)
  let $newrows := rowset-fold(complete($states,$chart,?,$newindex,?),$newrows,$newrows)
  let $chart := array:put($chart,$newindex,$newrows)
  return parse($states,$chart,$newindex,fn:tail($tokens))
};

declare %private function complete($states,$chart,$rows,$index,$row)
{
  $row(function($nte,$te,$tv,$fns,$sid,$parent,$bases) {
    fn:fold-left(function($rows,$c) { (: for each complete category :)

      let $c_ := $c()
      let $category := fn:head($c_)
      let $newbases := fn:tail($c_)($bases)
      return fn:fold-left(function($rows,$prow) { (: for each parent row :)

        $prow(function($pnte,$pte,$ptv,$pc,$psid,$pparent,$pbases) {
          let $id := $pnte($category)
          return if(fn:empty($id)) then $rows else
            let $row := row($states,$id,$pparent,($pbases,$newbases))
            return if(rowset-contains($rows,$row)) then $rows else
              let $rows := epsilon-expand($states,$rows,$index,$row)
              return complete($states,$chart,$rows,$index,$row)
        })
      },$rows,chart-get($chart,$parent))
    },$rows,$fns)
  })
};

declare %private function find-result($tokens,$chart)
{
  let $chart-size := array:size($chart)
  let $rows := chart-get($chart,$chart-size - 1)
  return if(fn:empty($rows)) then
    parse-error($tokens,$chart-size - 1,chart-get($chart,$chart-size - 2))
  else
  let $r :=
    fn:fold-left(function($r,$row) {
      if(fn:head($r)) then $r else
      $row(function($nte,$te,$tv,$fns,$sid,$parent,$bases) {
        fn:fold-left(function($r,$c) {
          let $c_ := $c()
          let $category := fn:head($c_)
          let $fn := fn:tail($c_)
          return if(fn:head($r) or $category ne $p:start-id) then $r
            else (fn:true(),$fn($bases))
        },fn:false(),$fns)
      })
    },fn:false(),$rows)
  return if(fn:not(fn:head($r))) then
    parse-error($tokens,$chart-size,$rows)
  else fn:tail($r)
};

declare %private function parse-error($tokens,$i,$rows)
{
  let $etokens := fn:distinct-values(fn:fold-left(function($etokens,$row) {
    $etokens,
    $row(function($nte,$te,$tv,$c,$sid,$parent,$bases) { $tv })
  },(),$rows))
  let $expected := if(fn:exists($etokens)) then "'" || fn:string-join($etokens,"', '") || "'"
    else "<EOF>"
  let $found := fn:subsequence($tokens,$i,1)
  let $found := if(fn:empty($found)) then "<EOF>" else codepoint($found)
  let $line-breaks := fn:index-of($tokens,10)
  let $line := fn:count($line-breaks[. lt $i]) + 1
  let $column := $i - ($line-breaks[. lt $i][fn:last()],0)[1] - 1
  return fn:error(xs:QName("p:ERROR"),"Parse error, expecting: " || $expected ||
    ", found: '" || $found || "', at: " || $line || ":" || $column)
};
