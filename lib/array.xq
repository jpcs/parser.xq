xquery version "3.0";

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

module namespace hmap = "http://snelson.org.uk/functions/array";
declare default function namespace "http://snelson.org.uk/functions/array";
import module namespace hamt = "http://snelson.org.uk/functions/hamt" at "hamt.xq";

declare function entry($key as xs:integer, $value as item()*)
{
  function() { $key, $value }
};

declare %private function key($pair as item()) as xs:integer
{
  fn:head($pair())
};

declare %private function value($pair as item())
{
  fn:tail($pair())
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
  $key as xs:integer,
  $value as item()*
) as item()
{
  hamt:put(key#1, eq#2, $map, entry($key, $value))
};

declare function delete(
  $map as item(),
  $key as xs:integer
) as item()
{
  hamt:delete(key#1, eq#2, $map, entry($key, ()))
};

declare function get($map as item(), $key as xs:integer)
  as item()*
{
  hamt:get(key#1, eq#2, $map, entry($key, ())) ! value(.)
};

declare function contains($map as item(), $key as xs:integer)
  as xs:boolean
{
  hamt:contains(key#1, eq#2, $map, entry($key, ()))
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

declare function size($map as item()) as xs:integer
{
  hamt:fold(
    function($result, $pair) {
      fn:max(($result,key($pair)))
    }, -1, $map) + 1
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
