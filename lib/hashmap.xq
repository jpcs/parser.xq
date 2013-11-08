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

module namespace hmap = "http://snelson.org.uk/functions/hashmap";
declare default function namespace "http://snelson.org.uk/functions/hashmap";
import module namespace hamt = "http://snelson.org.uk/functions/hamt" at "hamt.xq";

declare function entry($key as xs:string, $value as item()*) as function() as item()*
{
  function() { $key, $value }
};

declare %private function key($pair)
{
  fn:head($pair())
};

declare %private function value($pair)
{
  fn:tail($pair())
};

declare %private function hash($a as item()) as xs:integer
{
  xs:integer(fn:fold-left(
    function($z,$v) { (($z + $v) * 8947693) mod 4294967296 },
    2489012344,
    fn:string-to-codepoints(key($a))
  ))
};

declare %private function eq($a as item(), $b as item()) as xs:boolean
{
  key($a) eq key($b)
};

declare function create() as item()
{
  hamt:create()
};

declare function put(
  $map as item(),
  $key as xs:string,
  $value as item()*
) as item()
{
  hamt:put(hash#1, eq#2, $map, entry($key, $value))
};

declare function put(
  $map as item(),
  $entry as function() as item()*
) as item()
{
  hamt:put(hash#1, eq#2, $map, $entry)
};

declare function delete(
  $map as item(),
  $key as xs:string
) as item()
{
  hamt:delete(hash#1, eq#2, $map, entry($key, ()))
};

declare function get($map as item(), $key as xs:string)
  as item()*
{
  hamt:get(hash#1, eq#2, $map, entry($key, ())) ! value(.)
};

declare function contains($map as item(), $key as item())
  as xs:boolean
{
  hamt:contains(hash#1, eq#2, $map, entry($key, ()))
};

declare function fold(
  $f as function(item()*, item(), item()*) as item()*,
  $z as item()*,
  $map as item()
) as item()*
{
  hamt:fold(
    function($result, $pair) {
      $f($result, key($pair), value($pair))
    },
    $z, $map)
};

declare function count($map as item()) as xs:integer
{
  hamt:count($map)
};

declare function empty($map as item()) as xs:boolean
{
  hamt:empty($map)
};

declare function is($map as item()) as xs:boolean
{
  hamt:is($map)
};
