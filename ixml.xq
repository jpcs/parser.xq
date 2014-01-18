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

module namespace ix = "http://snelson.org.uk/functions/ixml";
declare namespace err = "http://www.w3.org/2005/xqt-errors";
import module namespace ixp = "http://snelson.org.uk/functions/ixml-parser" at "lib/ixml-parser.xq";
import module namespace p = "http://snelson.org.uk/functions/parser" at "parser.xq";

declare %private variable $isMarkLogic as xs:boolean external :=
  fn:exists(fn:function-lookup(fn:QName("http://marklogic.com/xdmp","functions"),0));

declare %private variable $eval := (
  fn:function-lookup(fn:QName("http://marklogic.com/xdmp","eval"),1),
  function($s) { fn:error(xs:QName("p:EVAL"),"Eval function unknown for this XQuery processor") }
)[1];

declare function ix:make-parser($grammar as xs:string)
  as function(xs:string) as element()
{
  let $p :=
    if($ix:isMarkLogic) then 
      let $moduleURI := fn:replace(try { fn:error() } catch * { $err:module },"^(.*/)[^/]*$","$1")
      return $eval('
xquery version "3.0";
import module namespace ixp = "http://snelson.org.uk/functions/ixml-parser" at "' || $moduleURI || 'lib/ixml-parser-ml.xq";
import module namespace p = "http://snelson.org.uk/functions/parser" at "' || $moduleURI || 'parser.xq";
function($grammar) { p:make-parser(ixp:parse($grammar),"eval") }
    ')($grammar)
    else p:make-parser(ixp:parse($grammar))
  return function($ixml) { $p($ixml)() }
};

declare function ix:parse($grammar as xs:string, $ixml as xs:string)
  as element()
{
  ix:make-parser($grammar)($ixml)
};
