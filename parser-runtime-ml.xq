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

module namespace p = "http://snelson.org.uk/functions/parser-runtime";
declare default function namespace "http://snelson.org.uk/functions/parser-runtime";

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
 : Chart = array(integer,RowSet)
 : RowSet = map(string,Row)
 : Row =
 :   "nte" as integer*,
 :   "te" as integer*,
 :   "c" as (integer,ActionFunction)*,
 :   "sid" as integer,
 :   "parent" as integer,
 :   "bases" as item()*
 : States =
 :   "nt-edges" as (integer*)*,
 :   "t-edges" as (integer*)*,
 :   "complete" as ((integer,ActionFunction)*)*,
 :   "nt-names" as string*
 :)

declare %private function states($nt-edges,$t-edges,$t-values,$complete,$nt-names)
{
  map:get(map:new((
    map:entry("nt-edges",$nt-edges),
    map:entry("t-edges",$t-edges),
    map:entry("t-values",$t-values),
    map:entry("complete",$complete),
    map:entry("nt-names",$nt-names)
  )),?)
};

declare %private function row($states,$sid,$parent,$bases)
{
  let $i := $sid + 1
  let $nte := $states("nt-edges")[$i]
  let $te := $states("t-edges")[$i]
  let $tv := $states("t-values")[$i]()
  let $c := $states("complete")[$i]()
  return map:get(map:new((
    map:entry("nte",$nte),
    map:entry("te",$te),
    map:entry("tv",$tv),
    map:entry("c",$c),
    map:entry("sid",$sid),
    map:entry("parent",$parent),
    map:entry("bases",$bases)
  )),?)
};

declare %private function row-hash($row)
{
  $row("sid") || "/" || $row("parent")
};

declare %private function rowset() as item()
{
  map:map()
};

declare %private function rowset-put(
  $set as item(),
  $states,
  $sid,
  $parent
)
{
  let $k := $sid || "/" || $parent
  where fn:not(map:contains($set,$k))
  return
    let $row := row($states,$sid,$parent,())
    return (
      map:put($set,$k,fn:true()),
      map:put($set,"rows",(map:get($set,"rows"),$row)),
      $row
    )
};

declare %private function rowset-put-from(
  $set as item(),
  $states,
  $sid,
  $row,
  $newbases
)
{
  let $parent := $row("parent")
  let $k := $sid || "/" || $parent
  where fn:not(map:contains($set,$k))
  return
    let $row := row($states,$sid,$parent,($row("bases"),$newbases))
    return (
      map:put($set,$k,fn:true()),
      map:put($set,"rows",(map:get($set,"rows"),$row)),
      $row
    )
};

declare %private function rowset-rows(
  $set as item()
) as item()*
{
  map:get($set,"rows")
};

declare %private function rowset-fold(
  $f as function(item()*, item()) as item()*,
  $z as item()*,
  $set as item()
) as item()*
{
  fn:fold-left($f,$z,map:get($set,"rows"))
};

declare %private function chart($states)
{
  let $rows := rowset()
  let $chart := json:array()
  return (
    for $row in rowset-put($rows,$states,0,1)
    return epsilon-expand($states,$rows,1,$row),
    chart-push($chart,$rows),
    $chart
  )
};

declare %private function chart-size($chart)
{
  json:array-size($chart)
};

declare %private function chart-push($chart,$rowset)
{
  let $rows := rowset-rows($rowset)
  return json:array-push($chart,$rows)
};

declare %private function chart-get($chart,$index)
{
  $chart[$index]
};

declare function chart-as-string($chart)
{
  fn:string-join(
    for $index in (1 to (json:array-size($chart)))
    let $rows := chart-get($chart,$index)
    return (
      "========== Chart " || $index || " (" || fn:count($rows) || " rows) ==========",
      for $row in $rows
      return (
        $index || ": State: " || $row("sid") || ", Parent Chart:" || $row("parent") || ", Bases: " || fn:count($row("bases")),
        $index || ":   complete: (" || fn:string-join($row("c") ! fn:string(fn:head(.())),",") || ")"
      )
    )
  ,"&#10;")
};

declare %private function epsilon-expand($states,$rows,$index,$row)
{
  for $id in $row("nte")($p:epsilon-id)
  for $row in rowset-put($rows,$states,$id,$index)
  return epsilon-expand($states,$rows,$index,$row)
};

declare function make-parser($nt-edges,$t-edges,$t-values,$complete,$nt-names)
{
  let $states := states($nt-edges,$t-edges,$t-values,$complete,$nt-names)
  return function($s) {
    let $tokens := fn:string-to-codepoints($s)
    let $chart := parse($states,$tokens)
    (: let $_ := xdmp:log(chart-as-string($chart)) :)
    return find-result($tokens,$chart)
  }
};

declare %private function parse($states,$tokens)
{
  let $chart := chart($states)
  return (

  for $token at $index in $tokens
  let $rows := chart-get($chart,$index)
  where fn:exists($rows)
  return

  let $newindex := $index + 1
  let $newrows := rowset()
  return (
    for $row in $rows
    return scan($states,$newrows,$newindex,$token,$row),

    for $row in rowset-rows($newrows)
    return complete($states,$chart,$newrows,$newindex,$row),

    chart-push($chart,$newrows)
  ),

  $chart
  )
};

declare %private function scan($states,$rows,$index,$token,$row)
{
  for $id in $row("te")($token)
  for $row in rowset-put-from($rows,$states,$id,$row,$token)
  return epsilon-expand($states,$rows,$index,$row)
};

declare %private function complete($states,$chart,$rows,$index,$row)
{
  for $c in $row("c")
  let $c_ := $c()
  let $category := fn:head($c_)
  let $newbases := fn:tail($c_)($row("bases"))

  for $prow in chart-get($chart,$row("parent"))
  for $id in $prow("nte")($category)
  for $row in rowset-put-from($rows,$states,$id,$prow,$newbases)
  return (
    epsilon-expand($states,$rows,$index,$row),
    complete($states,$chart,$rows,$index,$row)
  )
};

declare %private function find-result($tokens,$chart)
{
  let $chart-size := chart-size($chart)
  let $rows := chart-get($chart,$chart-size)
  return if(fn:empty($rows)) then
    parse-error($tokens,$chart-size - 1,chart-get($chart,$chart-size - 1))
  else
  let $r :=
    fn:fold-left(function($r,$row) {
      if(fn:head($r) or $row("parent") ne 1) then $r else
        fn:fold-left(function($r,$c) {
          let $c_ := $c()
          let $category := fn:head($c_)
          let $fn := fn:tail($c_)
          return if(fn:head($r) or $category ne $p:start-id) then $r
            else (fn:true(),$fn($row("bases")))
        },fn:false(),$row("c"))
    },fn:false(),$rows)
  return if(fn:not(fn:head($r))) then
    parse-error($tokens,$chart-size,$rows)
  else fn:tail($r)
};

declare %private function parse-error($tokens,$i,$rows)
{
  let $etokens := fn:distinct-values(fn:fold-left(function($etokens,$row) {
    $etokens,$row("tv")
  },(),$rows))
  let $expected := if(fn:exists($etokens)) then "'" || fn:string-join($etokens,"', '") || "'"
    else "<EOF>"
  let $found := fn:subsequence($tokens,$i,1)
  let $found := if(empty($found)) then "<EOF>" else codepoint($found)
  let $line-breaks := fn:index-of($tokens,10)
  let $line := fn:count($line-breaks[. lt $i]) + 1
  let $column := $i - ($line-breaks[. lt $i][last()],0)[1] - 1
  return fn:error(xs:QName("p:ERROR"),"Parse error, expecting: " || $expected ||
    ", found: '" || $found || "', at: " || $line || ":" || $column)
};
