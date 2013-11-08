xquery version "1.0-ml";

(:
 : Copyright (c) 2010-2012 John Snelson
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

module namespace hamt = "http://snelson.org.uk/functions/hamt";
declare default function namespace "http://snelson.org.uk/functions/hamt";

declare %private variable $hamt:width := 32;
declare %private variable $hamt:split := 16;

declare %private variable $hamt:empty := function($empty,$leaf,$index) { $empty() };
declare %private variable $hamt:empty-index-children := (1 to $hamt:width) ! $hamt:empty;
declare %private variable $hamt:empty-index := function($empty,$leaf,$index) { $index($hamt:empty-index-children) };
declare %private function leaf($values) { function($empty,$leaf,$index) { $leaf($values) } };
declare %private function index($children) { function($empty,$leaf,$index) { $index($children) } };

declare function is($hamt as item()) as xs:boolean
{
  try {
    $hamt(
      (: Empty :) fn:true#0,
      (: Leaf :) function($a) { fn:true() },
      (: Index :) function($a) { fn:true() }
    )
  } catch * { fn:false() }
};

declare function create() as item() { $hamt:empty };

declare function put(
  $hf as function(item()) as xs:integer,
  $eq as function(item(),item()) as xs:boolean,
  $hamt as item(),
  $k as item()
) as item()
{
  put-helper($hf,$eq,$hamt,$k,$hf($k))
};

declare %private function put-helper($hf,$eq,$hamt,$k,$hash)
{
  $hamt(
    (: Empty :) function() {
      leaf($k)
    },
    (: Leaf :) function($values) {
      if(fn:count($values) eq $hamt:split) then
        fn:fold-left(function($hamt,$v) {
          put-helper($hf,$eq,$hamt,$v,$hf($v))
        },$hamt:empty-index,$values)
          ! put-helper($hf,$eq,.,$k,$hash)
      else leaf(($k, $values[fn:not($eq(.,$k))]))
    },
    (: Index :) function($children) {
      index(
        let $i := ($hash mod $hamt:width) + 1
        let $hashleft := $hash idiv $hamt:width
        let $newhf := function($v) { $hf($v) idiv $hamt:width }
        for $c at $p in $children
        return
          if($p ne $i) then $c
          else put-helper($newhf,$eq,$c,$k,$hashleft)
      )
    }
  )
};

declare function delete(
  $hf as function(item()) as xs:integer,
  $eq as function(item(),item()) as xs:boolean,
  $hamt as item(),
  $k as item()
) as item()
{
  delete-helper($eq,$hamt,$k,$hf($k))
};

declare %private function delete-helper($eq,$hamt,$k,$hash)
{
  $hamt(
    (: Empty :) function() { $hamt:empty },
    (: Leaf :) function($values) {
      let $newvalues := $values[fn:not($eq(.,$k))]
      return if(fn:empty($newvalues)) then $hamt:empty else leaf($newvalues)
    },
    (: Index :) function($children) {
      let $newindex := index(
        let $i := ($hash mod $hamt:width) + 1
        let $hashleft := $hash idiv $hamt:width
        for $c at $p in $children
        return
          if($p ne $i) then $c
          else delete-helper($eq,$c,$k,$hashleft)
      )
      return if(empty-helper($newindex)) then $hamt:empty else $newindex
    }
  )
};

declare function get(
  $hf as function(item()) as xs:integer,
  $eq as function(item(),item()) as xs:boolean,
  $hamt as item(),
  $k as item()
) as item()?
{
  get-helper($eq,$hamt,$k,$hf($k))
};

declare function contains(
  $hf as function(item()) as xs:integer,
  $eq as function(item(),item()) as xs:boolean,
  $hamt as item(),
  $k as item()
) as xs:boolean
{
  fn:exists(get($hf,$eq,$hamt,$k))
};

declare %private function get-helper($eq,$hamt,$k,$hash)
{
  $hamt(
    (: Empty :) function() { () },
    (: Leaf :) function($values) {
      $values[$eq(.,$k)]
    },
    (: Index :) function($children) {
      let $i := ($hash mod $hamt:width) + 1
      let $hashleft := $hash idiv $hamt:width
      return get-helper($eq,$children[$i],$k,$hashleft)
    }
  )
};

declare function describe(
  $hamt as item()
) as xs:string
{
  describe-helper($hamt,1)
};

declare %private function describe-helper($hamt,$indent)
{
  $hamt(
    (: Empty :) function() { "[Empty]" },
    (: Leaf :) function($values) {
      "[Leaf (" || fn:string-join($values ! ('"' || fn:string(.) || '"'),", ") || ")]"
    },
    (: Index :) function($children) {
      "[Index" || $children ! (
        "&#xa;" || fn:string-join(((1 to $indent) ! "  ")) || describe-helper(.,$indent + 1))
      || "]"
    }
  )
};

declare function fold(
  $f as function(item()*,item()) as item()*,
  $z as item()*,
  $hamt as item()
) as item()*
{
  fold-helper($f,$z,$hamt)  
};

declare %private function fold-helper($f,$z,$hamt)
{
  $hamt(
    (: Empty :) function() { $z },
    (: Leaf :) fn:fold-left($f,$z,?),
    (: Index :) fn:fold-left(fold-helper($f,?,?),$z,?)
  )
};

declare function count(
  $hamt as item()
) as xs:integer
{
  count-helper($hamt)  
};

declare %private function count-helper($hamt)
{
  $hamt(
    (: Empty :) function() { 0 },
    (: Leaf :) fn:count#1,
    (: Index :) fn:fold-left(function($z,$c) { $z + count-helper($c) },0,?)
  )
};

declare function empty(
  $hamt as item()
) as xs:boolean
{
  empty-helper($hamt)
};

declare %private function empty-helper($hamt)
{
  $hamt(
    (: Empty :) fn:true#0,
    (: Leaf :) fn:empty#1,
    (: Index :) fn:fold-left(function($z,$c) { $z and empty-helper($c) },fn:true(),?)
  )
};
