xquery version "3.0";
module namespace x = "http://snelson.org.uk/functions/ixml-parser";
import module namespace gr = "http://snelson.org.uk/functions/grammar" at "../grammar.xq";
import module namespace p = 'http://snelson.org.uk/functions/parser-runtime' at '/parser.xq/parser-runtime-ml.xq';
declare %private function x:ref($s) { function() { $s } };
declare %private variable $x:states := (
  p:state(0,(),
    function($c) { switch($c) case 0 return 1 case 1 return 0 case 3 return 2 default return () },
    function($c) { () },
    ()),
  p:state(1,("\t","\n","\r"," ","[a-z]","[A-Z]"),
    function($c) { switch($c) case 1 return 8 case 3 return 73 case 4 return 79 case 39 return 5 case 40 return 13 case 41 return 7 default return () },
    function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) default return (),  if(97 le $c and $c le 122) then (9) else (), if(65 le $c and $c le 90) then (9) else () },
    ()),
  p:state(2,(),
    function($c) { switch($c) case 0 return 3 case 1 return 2 default return () },
    function($c) { () },
    (
      x:ref((2,function($ch) {
gr:grammar($ch)
      })))),
  p:state(3,("\t","\n","\r"," "),
    function($c) { switch($c) case 41 return 7 default return () },
    function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) default return () },
    ()),
  p:state(4,(),
    function($c) { () },
    function($c) { () },
    (
      x:ref((41,function($ch) {
()
      })))),
  p:state(5,(),
    function($c) { switch($c) case 0 return 6 case 1 return 5 case 6 return 10 default return () },
    function($c) { () },
    ()),
  p:state(6,("\t","\n","\r"," ",":"),
    function($c) { switch($c) case 41 return 7 default return () },
    function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 58 return (78) default return () },
    ()),
  p:state(7,(),
    function($c) { () },
    function($c) { () },
    (
      x:ref((1,function($ch) {
()
      })))),
  p:state(8,("[a-z]","[A-Z]"),
    function($c) { switch($c) case 0 return 1 case 1 return 8 case 3 return 73 case 4 return 79 case 39 return 5 case 40 return 13 default return () },
    function($c) { if(97 le $c and $c le 122) then (9) else (), if(65 le $c and $c le 90) then (9) else () },
    ()),
  p:state(9,(),
    function($c) { switch($c) case 0 return 3 case 1 return 9 default return () },
    function($c) { () },
    (
      x:ref((40,function($ch) {
$ch
      })))),
  p:state(10,(),
    function($c) { switch($c) case 0 return 11 case 1 return 10 case 5 return 31 case 7 return 106 default return () },
    function($c) { () },
    ()),
  p:state(11,("\t","\n","\r"," ","\&quot;","(","+","-",".",";","@","[A-Z]","[a-z]"),
    function($c) { switch($c) case 1 return 38 case 8 return 14 case 9 return 16 case 10 return 18 case 11 return 48 case 13 return 36 case 14 return 19 case 15 return 28 case 18 return 32 case 19 return 28 case 22 return 34 case 25 return 19 case 26 return 12 case 27 return 47 case 28 return 40 case 29 return 47 case 30 return 12 case 31 return 12 case 32 return 20 case 33 return 12 case 34 return 37 case 35 return 42 case 38 return 50 case 39 return 58 case 40 return 13 case 41 return 7 default return () },
    function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 34 return (43) case 40 return (29) case 43 return (27) case 45 return (24) case 46 return (23) case 59 return (22) case 64 return (44) default return (),  if(65 le $c and $c le 90) then (9) else (), if(97 le $c and $c le 122) then (9) else () },
    (
      x:ref((8,function($ch) {
$ch
      })),
      x:ref((10,function($ch) {
gr:sequence($ch)
      })),
      x:ref((7,function($ch) {
gr:nchoice($ch)
      })))),
  p:state(12,(),
    function($c) { switch($c) case 0 return 3 case 1 return 12 default return () },
    function($c) { () },
    (
      x:ref((25,function($ch) {
$ch
      })))),
  p:state(13,("[a-z]","[A-Z]"),
    function($c) { switch($c) case 0 return 3 case 1 return 13 default return () },
    function($c) { if(97 le $c and $c le 122) then (9) else (), if(65 le $c and $c le 90) then (9) else () },
    (
      x:ref((39,function($ch) {
fn:codepoints-to-string($ch)
      })))),
  p:state(14,(),
    function($c) { switch($c) case 0 return 15 case 1 return 14 case 9 return 16 default return () },
    function($c) { () },
    (
      x:ref((7,function($ch) {
gr:nchoice($ch)
      })))),
  p:state(15,("\t","\n","\r"," ",";"),
    function($c) { switch($c) case 41 return 7 default return () },
    function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 59 return (22) default return () },
    ()),
  p:state(16,(),
    function($c) { switch($c) case 0 return 17 case 1 return 16 case 10 return 18 default return () },
    function($c) { () },
    (
      x:ref((8,function($ch) {
$ch
      })))),
  p:state(17,("\t","\n","\r"," ","\&quot;","(","+","-","@","[A-Z]","[a-z]"),
    function($c) { switch($c) case 1 return 102 case 11 return 48 case 13 return 36 case 14 return 19 case 15 return 28 case 18 return 32 case 19 return 28 case 22 return 34 case 25 return 19 case 26 return 12 case 27 return 47 case 28 return 40 case 29 return 47 case 30 return 12 case 31 return 12 case 32 return 20 case 33 return 12 case 34 return 37 case 35 return 42 case 38 return 50 case 39 return 58 case 40 return 13 case 41 return 7 default return () },
    function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 34 return (43) case 40 return (29) case 43 return (27) case 45 return (24) case 64 return (44) default return (),  if(65 le $c and $c le 90) then (9) else (), if(97 le $c and $c le 122) then (9) else () },
    (
      x:ref((10,function($ch) {
gr:sequence($ch)
      })))),
  p:state(18,(),
    function($c) { switch($c) case 0 return 3 case 1 return 18 default return () },
    function($c) { () },
    (
      x:ref((8,function($ch) {
$ch
      })))),
  p:state(19,(),
    function($c) { switch($c) case 0 return 3 case 1 return 19 default return () },
    function($c) { () },
    (
      x:ref((13,function($ch) {
$ch
      })))),
  p:state(20,(),
    function($c) { switch($c) case 0 return 21 case 1 return 20 case 39 return 30 default return () },
    function($c) { () },
    ()),
  p:state(21,("\t","\n","\r"," ","[A-Z]","[a-z]"),
    function($c) { switch($c) case 1 return 25 case 40 return 13 case 41 return 7 default return () },
    function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) default return (),  if(65 le $c and $c le 90) then (9) else (), if(97 le $c and $c le 122) then (9) else () },
    ()),
  p:state(22,(),
    function($c) { () },
    function($c) { () },
    (
      x:ref((9,function($ch) {
()
      })))),
  p:state(23,(),
    function($c) { () },
    function($c) { () },
    (
      x:ref((5,function($ch) {
()
      })))),
  p:state(24,(),
    function($c) { () },
    function($c) { () },
    (
      x:ref((32,function($ch) {
()
      })))),
  p:state(25,("[A-Z]","[a-z]"),
    function($c) { switch($c) case 0 return 26 case 1 return 25 case 40 return 13 default return () },
    function($c) { if(65 le $c and $c le 90) then (9) else (), if(97 le $c and $c le 122) then (9) else () },
    ()),
  p:state(26,("\t","\n","\r"," ","[A-Z]","[a-z]"),
    function($c) { switch($c) case 1 return 60 case 40 return 68 case 41 return 7 default return () },
    function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) default return (),  if(65 le $c and $c le 90) then (9) else (), if(97 le $c and $c le 122) then (9) else () },
    ()),
  p:state(27,(),
    function($c) { () },
    function($c) { () },
    (
      x:ref((28,function($ch) {
()
      })))),
  p:state(28,(),
    function($c) { switch($c) case 0 return 3 case 1 return 28 default return () },
    function($c) { () },
    (
      x:ref((14,function($ch) {
$ch
      })))),
  p:state(29,(),
    function($c) { () },
    function($c) { () },
    (
      x:ref((18,function($ch) {
()
      })),
      x:ref((22,function($ch) {
()
      })))),
  p:state(30,(),
    function($c) { switch($c) case 0 return 3 case 1 return 30 default return () },
    function($c) { () },
    (
      x:ref((31,function($ch) {
gr:non-term($ch)
      })))),
  p:state(31,(),
    function($c) { switch($c) case 0 return 3 case 1 return 31 default return () },
    function($c) { () },
    (
      x:ref((4,function($ch) {
gr:rule(fn:head($ch),fn:tail($ch))
      })))),
  p:state(32,(),
    function($c) { switch($c) case 0 return 33 case 1 return 32 case 7 return 63 case 17 return 66 default return () },
    function($c) { () },
    ()),
  p:state(33,("\t","\n","\r"," ","\&quot;","(",")","+","-",";","@","[A-Z]","[a-z]"),
    function($c) { switch($c) case 1 return 38 case 8 return 14 case 9 return 16 case 10 return 18 case 11 return 48 case 13 return 36 case 14 return 19 case 15 return 28 case 18 return 32 case 19 return 28 case 22 return 34 case 25 return 19 case 26 return 12 case 27 return 47 case 28 return 40 case 29 return 47 case 30 return 12 case 31 return 12 case 32 return 20 case 33 return 12 case 34 return 37 case 35 return 42 case 38 return 50 case 39 return 58 case 40 return 13 case 41 return 7 default return () },
    function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 34 return (43) case 40 return (29) case 41 return (65) case 43 return (27) case 45 return (24) case 59 return (22) case 64 return (44) default return (),  if(65 le $c and $c le 90) then (9) else (), if(97 le $c and $c le 122) then (9) else () },
    (
      x:ref((8,function($ch) {
$ch
      })),
      x:ref((10,function($ch) {
gr:sequence($ch)
      })),
      x:ref((7,function($ch) {
gr:nchoice($ch)
      })))),
  p:state(34,(),
    function($c) { switch($c) case 0 return 35 case 1 return 34 case 7 return 45 case 21 return 88 default return () },
    function($c) { () },
    ()),
  p:state(35,("\t","\n","\r"," ","\&quot;","(",")","+","-",";","@","[A-Z]","[a-z]"),
    function($c) { switch($c) case 1 return 38 case 8 return 14 case 9 return 16 case 10 return 18 case 11 return 48 case 13 return 36 case 14 return 19 case 15 return 28 case 18 return 32 case 19 return 28 case 22 return 34 case 25 return 19 case 26 return 12 case 27 return 47 case 28 return 40 case 29 return 47 case 30 return 12 case 31 return 12 case 32 return 20 case 33 return 12 case 34 return 37 case 35 return 42 case 38 return 50 case 39 return 58 case 40 return 13 case 41 return 7 default return () },
    function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 34 return (43) case 40 return (29) case 41 return (77) case 43 return (27) case 45 return (24) case 59 return (22) case 64 return (44) default return (),  if(65 le $c and $c le 90) then (9) else (), if(97 le $c and $c le 122) then (9) else () },
    (
      x:ref((8,function($ch) {
$ch
      })),
      x:ref((10,function($ch) {
gr:sequence($ch)
      })),
      x:ref((7,function($ch) {
gr:nchoice($ch)
      })))),
  p:state(36,(),
    function($c) { switch($c) case 0 return 3 case 1 return 36 default return () },
    function($c) { () },
    (
      x:ref((11,function($ch) {
$ch
      })))),
  p:state(37,(),
    function($c) { switch($c) case 0 return 21 case 1 return 37 case 39 return 87 default return () },
    function($c) { () },
    ()),
  p:state(38,("[A-Z]","[a-z]"),
    function($c) { switch($c) case 0 return 39 case 1 return 38 case 8 return 14 case 9 return 16 case 10 return 18 case 11 return 48 case 13 return 36 case 14 return 19 case 15 return 28 case 18 return 32 case 19 return 28 case 22 return 34 case 25 return 19 case 26 return 12 case 27 return 47 case 28 return 40 case 29 return 47 case 30 return 12 case 31 return 12 case 32 return 20 case 33 return 12 case 34 return 37 case 35 return 42 case 39 return 58 case 40 return 13 default return () },
    function($c) { if(65 le $c and $c le 90) then (9) else (), if(97 le $c and $c le 122) then (9) else () },
    (
      x:ref((8,function($ch) {
$ch
      })),
      x:ref((10,function($ch) {
gr:sequence($ch)
      })),
      x:ref((7,function($ch) {
gr:nchoice($ch)
      })))),
  p:state(39,("\t","\n","\r"," ","\&quot;","(","+","-",";","@","[A-Z]","[a-z]"),
    function($c) { switch($c) case 1 return 59 case 8 return 80 case 9 return 16 case 10 return 18 case 11 return 48 case 13 return 36 case 14 return 19 case 15 return 28 case 18 return 32 case 19 return 28 case 22 return 34 case 25 return 19 case 26 return 12 case 27 return 47 case 28 return 40 case 29 return 47 case 30 return 12 case 31 return 12 case 32 return 20 case 33 return 12 case 34 return 37 case 35 return 42 case 38 return 50 case 39 return 58 case 40 return 13 case 41 return 7 default return () },
    function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 34 return (43) case 40 return (29) case 43 return (27) case 45 return (24) case 59 return (22) case 64 return (44) default return (),  if(65 le $c and $c le 90) then (9) else (), if(97 le $c and $c le 122) then (9) else () },
    (
      x:ref((8,function($ch) {
$ch
      })),
      x:ref((10,function($ch) {
gr:sequence($ch)
      })))),
  p:state(40,(),
    function($c) { switch($c) case 0 return 41 case 1 return 40 case 35 return 53 default return () },
    function($c) { () },
    ()),
  p:state(41,("\t","\n","\r"," ","\&quot;"),
    function($c) { switch($c) case 38 return 50 case 41 return 7 default return () },
    function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 34 return (43) default return () },
    ()),
  p:state(42,(),
    function($c) { switch($c) case 0 return 3 case 1 return 42 default return () },
    function($c) { () },
    (
      x:ref((29,function($ch) {
gr:term-($ch)
      })))),
  p:state(43,(),
    function($c) { () },
    function($c) { () },
    (
      x:ref((38,function($ch) {
()
      })))),
  p:state(44,(),
    function($c) { () },
    function($c) { () },
    (
      x:ref((34,function($ch) {
()
      })))),
  p:state(45,(),
    function($c) { switch($c) case 0 return 46 case 1 return 45 case 21 return 88 default return () },
    function($c) { () },
    ()),
  p:state(46,("\t","\n","\r"," ",")"),
    function($c) { switch($c) case 41 return 7 default return () },
    function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 41 return (77) default return () },
    ()),
  p:state(47,(),
    function($c) { switch($c) case 0 return 3 case 1 return 47 default return () },
    function($c) { () },
    (
      x:ref((26,function($ch) {
$ch
      })))),
  p:state(48,(),
    function($c) { switch($c) case 0 return 49 case 1 return 48 case 12 return 94 default return () },
    function($c) { () },
    (
      x:ref((10,function($ch) {
gr:sequence($ch)
      })))),
  p:state(49,("\t","\n","\r"," ",","),
    function($c) { switch($c) case 41 return 7 default return () },
    function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 44 return (54) default return () },
    ()),
  p:state(50,(),
    function($c) { switch($c) case 0 return 51 case 36 return 55 case 37 return 61 default return () },
    function($c) { () },
    ()),
  p:state(51,("\&quot;","[#-]","[\t-!]"),
    function($c) { switch($c) case 37 return 56 default return () },
    function($c) { switch($c) case 34 return (57) default return (),  if(35 le $c and $c le 127) then (52) else (), if(9 le $c and $c le 33) then (52) else () },
    (
      x:ref((37,function($ch) {
$ch
      })))),
  p:state(52,(),
    function($c) { () },
    function($c) { () },
    (
      x:ref((37,function($ch) {
$ch
      })))),
  p:state(53,(),
    function($c) { switch($c) case 0 return 3 case 1 return 53 default return () },
    function($c) { () },
    (
      x:ref((27,function($ch) {
gr:term($ch)
      })))),
  p:state(54,(),
    function($c) { () },
    function($c) { () },
    (
      x:ref((12,function($ch) {
()
      })))),
  p:state(55,(),
    function($c) { () },
    function($c) { () },
    (
      x:ref((35,function($ch) {
fn:codepoints-to-string($ch)
      })))),
  p:state(56,("[\t-!]","[#-]"),
    function($c) { () },
    function($c) { if(9 le $c and $c le 33) then (52) else (), if(35 le $c and $c le 127) then (52) else () },
    ()),
  p:state(57,(),
    function($c) { () },
    function($c) { () },
    (
      x:ref((36,function($ch) {
()
      })))),
  p:state(58,(),
    function($c) { switch($c) case 0 return 3 case 1 return 58 default return () },
    function($c) { () },
    (
      x:ref((30,function($ch) {
gr:non-term($ch)
      })))),
  p:state(59,("[a-z]","[A-Z]"),
    function($c) { switch($c) case 0 return 39 case 1 return 59 case 8 return 80 case 9 return 16 case 10 return 18 case 11 return 48 case 13 return 36 case 14 return 19 case 15 return 28 case 18 return 32 case 19 return 28 case 22 return 34 case 25 return 19 case 26 return 12 case 27 return 47 case 28 return 40 case 29 return 47 case 30 return 12 case 31 return 12 case 32 return 20 case 33 return 12 case 34 return 37 case 35 return 42 case 39 return 58 case 40 return 13 default return () },
    function($c) { if(97 le $c and $c le 122) then (9) else (), if(65 le $c and $c le 90) then (9) else () },
    (
      x:ref((8,function($ch) {
$ch
      })),
      x:ref((10,function($ch) {
gr:sequence($ch)
      })))),
  p:state(60,("[a-z]","[A-Z]"),
    function($c) { switch($c) case 0 return 26 case 1 return 60 case 40 return 68 default return () },
    function($c) { if(97 le $c and $c le 122) then (9) else (), if(65 le $c and $c le 90) then (9) else () },
    ()),
  p:state(61,(),
    function($c) { switch($c) case 0 return 62 case 36 return 55 default return () },
    function($c) { () },
    ()),
  p:state(62,("\&quot;"),
    function($c) { () },
    function($c) { switch($c) case 34 return (57) default return () },
    ()),
  p:state(63,(),
    function($c) { switch($c) case 0 return 64 case 1 return 63 case 17 return 66 default return () },
    function($c) { () },
    ()),
  p:state(64,("\t","\n","\r"," ",")"),
    function($c) { switch($c) case 41 return 7 default return () },
    function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 41 return (65) default return () },
    ()),
  p:state(65,(),
    function($c) { () },
    function($c) { () },
    (
      x:ref((17,function($ch) {
()
      })))),
  p:state(66,(),
    function($c) { switch($c) case 0 return 67 case 1 return 66 case 16 return 69 default return () },
    function($c) { () },
    ()),
  p:state(67,("\t","\n","\r"," ","+"),
    function($c) { switch($c) case 41 return 7 default return () },
    function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 43 return (72) default return () },
    ()),
  p:state(68,("[A-Z]","[a-z]"),
    function($c) { switch($c) case 0 return 3 case 1 return 68 default return () },
    function($c) { if(65 le $c and $c le 90) then (9) else (), if(97 le $c and $c le 122) then (9) else () },
    ()),
  p:state(69,(),
    function($c) { switch($c) case 0 return 70 case 1 return 69 case 23 return 71 default return () },
    function($c) { () },
    (
      x:ref((15,function($ch) {
gr:one-or-more($ch[1],$ch[2])
      })))),
  p:state(70,("\t","\n","\r"," ","\&quot;","+","-","@","[A-Z]","[a-z]"),
    function($c) { switch($c) case 1 return 75 case 24 return 93 case 25 return 93 case 26 return 12 case 27 return 47 case 28 return 40 case 29 return 47 case 30 return 12 case 31 return 12 case 32 return 20 case 33 return 12 case 34 return 37 case 35 return 42 case 38 return 50 case 39 return 58 case 40 return 13 case 41 return 7 default return () },
    function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 34 return (43) case 43 return (27) case 45 return (24) case 64 return (44) default return (),  if(65 le $c and $c le 90) then (9) else (), if(97 le $c and $c le 122) then (9) else () },
    (
      x:ref((24,function($ch) {
()
      })),
      x:ref((23,function($ch) {
$ch
      })))),
  p:state(71,(),
    function($c) { switch($c) case 0 return 3 case 1 return 71 default return () },
    function($c) { () },
    (
      x:ref((15,function($ch) {
gr:one-or-more($ch[1],$ch[2])
      })))),
  p:state(72,(),
    function($c) { () },
    function($c) { () },
    (
      x:ref((16,function($ch) {
()
      })))),
  p:state(73,(),
    function($c) { switch($c) case 0 return 74 case 1 return 73 case 4 return 79 default return () },
    function($c) { () },
    ()),
  p:state(74,("\t","\n","\r"," ","[A-Z]","[a-z]"),
    function($c) { switch($c) case 1 return 108 case 39 return 5 case 40 return 13 case 41 return 7 default return () },
    function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) default return (),  if(65 le $c and $c le 90) then (9) else (), if(97 le $c and $c le 122) then (9) else () },
    ()),
  p:state(75,("[A-Z]","[a-z]"),
    function($c) { switch($c) case 0 return 76 case 1 return 75 case 24 return 93 case 25 return 93 case 26 return 12 case 27 return 47 case 28 return 40 case 29 return 47 case 30 return 12 case 31 return 12 case 32 return 20 case 33 return 12 case 34 return 37 case 35 return 42 case 39 return 58 case 40 return 13 default return () },
    function($c) { if(65 le $c and $c le 90) then (9) else (), if(97 le $c and $c le 122) then (9) else () },
    (
      x:ref((24,function($ch) {
()
      })),
      x:ref((23,function($ch) {
$ch
      })))),
  p:state(76,("\t","\n","\r"," ","\&quot;","+","-","@","[A-Z]","[a-z]"),
    function($c) { switch($c) case 1 return 81 case 26 return 12 case 27 return 47 case 28 return 40 case 29 return 47 case 30 return 12 case 31 return 12 case 32 return 20 case 33 return 12 case 34 return 37 case 35 return 42 case 38 return 50 case 39 return 58 case 40 return 13 case 41 return 7 default return () },
    function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 34 return (43) case 43 return (27) case 45 return (24) case 64 return (44) default return (),  if(65 le $c and $c le 90) then (9) else (), if(97 le $c and $c le 122) then (9) else () },
    (
      x:ref((24,function($ch) {
()
      })))),
  p:state(77,(),
    function($c) { () },
    function($c) { () },
    (
      x:ref((21,function($ch) {
()
      })))),
  p:state(78,(),
    function($c) { () },
    function($c) { () },
    (
      x:ref((6,function($ch) {
()
      })))),
  p:state(79,(),
    function($c) { switch($c) case 0 return 3 case 1 return 79 default return () },
    function($c) { () },
    (
      x:ref((3,function($ch) {
$ch
      })))),
  p:state(80,(),
    function($c) { switch($c) case 0 return 15 case 1 return 80 case 9 return 16 default return () },
    function($c) { () },
    ()),
  p:state(81,("[a-z]","[A-Z]"),
    function($c) { switch($c) case 0 return 82 case 1 return 81 case 26 return 12 case 27 return 47 case 28 return 40 case 29 return 47 case 30 return 12 case 31 return 12 case 32 return 20 case 33 return 12 case 34 return 37 case 35 return 42 case 39 return 58 case 40 return 13 default return () },
    function($c) { if(97 le $c and $c le 122) then (9) else (), if(65 le $c and $c le 90) then (9) else () },
    (
      x:ref((24,function($ch) {
()
      })))),
  p:state(82,("\t","\n","\r"," ","\&quot;","+","-","@","[a-z]","[A-Z]"),
    function($c) { switch($c) case 1 return 83 case 27 return 47 case 28 return 40 case 29 return 47 case 32 return 20 case 34 return 37 case 35 return 42 case 38 return 50 case 39 return 58 case 40 return 13 case 41 return 7 default return () },
    function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 34 return (43) case 43 return (27) case 45 return (24) case 64 return (44) default return (),  if(97 le $c and $c le 122) then (9) else (), if(65 le $c and $c le 90) then (9) else () },
    ()),
  p:state(83,("[A-Z]","[a-z]"),
    function($c) { switch($c) case 0 return 84 case 1 return 83 case 27 return 47 case 28 return 40 case 29 return 47 case 32 return 20 case 34 return 37 case 35 return 42 case 39 return 58 case 40 return 13 default return () },
    function($c) { if(65 le $c and $c le 90) then (9) else (), if(97 le $c and $c le 122) then (9) else () },
    ()),
  p:state(84,("\t","\n","\r"," ","\&quot;","+","-","@","[a-z]","[A-Z]"),
    function($c) { switch($c) case 1 return 85 case 28 return 40 case 35 return 42 case 38 return 50 case 40 return 13 case 41 return 7 default return () },
    function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 34 return (43) case 43 return (27) case 45 return (24) case 64 return (44) default return (),  if(97 le $c and $c le 122) then (9) else (), if(65 le $c and $c le 90) then (9) else () },
    ()),
  p:state(85,("[A-Z]","[a-z]"),
    function($c) { switch($c) case 0 return 86 case 1 return 85 case 28 return 40 case 35 return 42 case 40 return 13 default return () },
    function($c) { if(65 le $c and $c le 90) then (9) else (), if(97 le $c and $c le 122) then (9) else () },
    ()),
  p:state(86,("\t","\n","\r"," ","\&quot;","+","[A-Z]","[a-z]"),
    function($c) { switch($c) case 1 return 60 case 38 return 50 case 40 return 68 case 41 return 7 default return () },
    function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 34 return (43) case 43 return (27) default return (),  if(65 le $c and $c le 90) then (9) else (), if(97 le $c and $c le 122) then (9) else () },
    ()),
  p:state(87,(),
    function($c) { switch($c) case 0 return 3 case 1 return 87 default return () },
    function($c) { () },
    (
      x:ref((33,function($ch) {
gr:non-term($ch)
      })))),
  p:state(88,(),
    function($c) { switch($c) case 0 return 89 case 1 return 88 case 20 return 91 default return () },
    function($c) { () },
    ()),
  p:state(89,("\t","\n","\r"," ","*"),
    function($c) { switch($c) case 41 return 7 default return () },
    function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 42 return (90) default return () },
    ()),
  p:state(90,(),
    function($c) { () },
    function($c) { () },
    (
      x:ref((20,function($ch) {
()
      })))),
  p:state(91,(),
    function($c) { switch($c) case 0 return 70 case 1 return 91 case 23 return 92 default return () },
    function($c) { () },
    (
      x:ref((19,function($ch) {
gr:zero-or-more($ch[1],$ch[2])
      })))),
  p:state(92,(),
    function($c) { switch($c) case 0 return 3 case 1 return 92 default return () },
    function($c) { () },
    (
      x:ref((19,function($ch) {
gr:zero-or-more($ch[1],$ch[2])
      })))),
  p:state(93,(),
    function($c) { switch($c) case 0 return 3 case 1 return 93 default return () },
    function($c) { () },
    (
      x:ref((23,function($ch) {
$ch
      })))),
  p:state(94,(),
    function($c) { switch($c) case 0 return 95 case 1 return 94 case 13 return 36 default return () },
    function($c) { () },
    ()),
  p:state(95,("\t","\n","\r"," ","\&quot;","(","+","-","@","[A-Z]","[a-z]"),
    function($c) { switch($c) case 1 return 96 case 14 return 19 case 15 return 28 case 18 return 32 case 19 return 28 case 22 return 34 case 25 return 19 case 26 return 12 case 27 return 47 case 28 return 40 case 29 return 47 case 30 return 12 case 31 return 12 case 32 return 20 case 33 return 12 case 34 return 37 case 35 return 42 case 38 return 50 case 39 return 58 case 40 return 13 case 41 return 7 default return () },
    function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 34 return (43) case 40 return (29) case 43 return (27) case 45 return (24) case 64 return (44) default return (),  if(65 le $c and $c le 90) then (9) else (), if(97 le $c and $c le 122) then (9) else () },
    ()),
  p:state(96,("[a-z]","[A-Z]"),
    function($c) { switch($c) case 0 return 97 case 1 return 96 case 14 return 19 case 15 return 28 case 18 return 32 case 19 return 28 case 22 return 34 case 25 return 19 case 26 return 12 case 27 return 47 case 28 return 40 case 29 return 47 case 30 return 12 case 31 return 12 case 32 return 20 case 33 return 12 case 34 return 37 case 35 return 42 case 39 return 58 case 40 return 13 default return () },
    function($c) { if(97 le $c and $c le 122) then (9) else (), if(65 le $c and $c le 90) then (9) else () },
    ()),
  p:state(97,("\t","\n","\r"," ","\&quot;","(","+","-","@","[a-z]","[A-Z]"),
    function($c) { switch($c) case 1 return 98 case 15 return 28 case 18 return 32 case 19 return 28 case 22 return 34 case 26 return 12 case 27 return 47 case 28 return 40 case 29 return 47 case 30 return 12 case 31 return 12 case 32 return 20 case 33 return 12 case 34 return 37 case 35 return 42 case 38 return 50 case 39 return 58 case 40 return 13 case 41 return 7 default return () },
    function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 34 return (43) case 40 return (29) case 43 return (27) case 45 return (24) case 64 return (44) default return (),  if(97 le $c and $c le 122) then (9) else (), if(65 le $c and $c le 90) then (9) else () },
    ()),
  p:state(98,("[A-Z]","[a-z]"),
    function($c) { switch($c) case 0 return 99 case 1 return 98 case 15 return 28 case 18 return 32 case 19 return 28 case 22 return 34 case 26 return 12 case 27 return 47 case 28 return 40 case 29 return 47 case 30 return 12 case 31 return 12 case 32 return 20 case 33 return 12 case 34 return 37 case 35 return 42 case 39 return 58 case 40 return 13 default return () },
    function($c) { if(65 le $c and $c le 90) then (9) else (), if(97 le $c and $c le 122) then (9) else () },
    ()),
  p:state(99,("\t","\n","\r"," ","\&quot;","(","+","-","@","[a-z]","[A-Z]"),
    function($c) { switch($c) case 1 return 100 case 18 return 32 case 22 return 34 case 27 return 47 case 28 return 40 case 29 return 47 case 32 return 20 case 34 return 37 case 35 return 42 case 38 return 50 case 39 return 58 case 40 return 13 case 41 return 7 default return () },
    function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 34 return (43) case 40 return (29) case 43 return (27) case 45 return (24) case 64 return (44) default return (),  if(97 le $c and $c le 122) then (9) else (), if(65 le $c and $c le 90) then (9) else () },
    ()),
  p:state(100,("[a-z]","[A-Z]"),
    function($c) { switch($c) case 0 return 101 case 1 return 100 case 18 return 32 case 22 return 34 case 27 return 47 case 28 return 40 case 29 return 47 case 32 return 20 case 34 return 37 case 35 return 42 case 39 return 58 case 40 return 13 default return () },
    function($c) { if(97 le $c and $c le 122) then (9) else (), if(65 le $c and $c le 90) then (9) else () },
    ()),
  p:state(101,("\t","\n","\r"," ","\&quot;","(","+","-","@","[a-z]","[A-Z]"),
    function($c) { switch($c) case 1 return 85 case 28 return 40 case 35 return 42 case 38 return 50 case 40 return 13 case 41 return 7 default return () },
    function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 34 return (43) case 40 return (29) case 43 return (27) case 45 return (24) case 64 return (44) default return (),  if(97 le $c and $c le 122) then (9) else (), if(65 le $c and $c le 90) then (9) else () },
    ()),
  p:state(102,("[a-z]","[A-Z]"),
    function($c) { switch($c) case 0 return 103 case 1 return 102 case 11 return 48 case 13 return 36 case 14 return 19 case 15 return 28 case 18 return 32 case 19 return 28 case 22 return 34 case 25 return 19 case 26 return 12 case 27 return 47 case 28 return 40 case 29 return 47 case 30 return 12 case 31 return 12 case 32 return 20 case 33 return 12 case 34 return 37 case 35 return 42 case 39 return 58 case 40 return 13 default return () },
    function($c) { if(97 le $c and $c le 122) then (9) else (), if(65 le $c and $c le 90) then (9) else () },
    (
      x:ref((10,function($ch) {
gr:sequence($ch)
      })))),
  p:state(103,("\t","\n","\r"," ","\&quot;","(","+","-","@","[A-Z]","[a-z]"),
    function($c) { switch($c) case 1 return 105 case 11 return 104 case 13 return 36 case 14 return 19 case 15 return 28 case 18 return 32 case 19 return 28 case 22 return 34 case 25 return 19 case 26 return 12 case 27 return 47 case 28 return 40 case 29 return 47 case 30 return 12 case 31 return 12 case 32 return 20 case 33 return 12 case 34 return 37 case 35 return 42 case 38 return 50 case 39 return 58 case 40 return 13 case 41 return 7 default return () },
    function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 34 return (43) case 40 return (29) case 43 return (27) case 45 return (24) case 64 return (44) default return (),  if(65 le $c and $c le 90) then (9) else (), if(97 le $c and $c le 122) then (9) else () },
    ()),
  p:state(104,(),
    function($c) { switch($c) case 0 return 49 case 1 return 104 case 12 return 94 default return () },
    function($c) { () },
    ()),
  p:state(105,("[a-z]","[A-Z]"),
    function($c) { switch($c) case 0 return 103 case 1 return 105 case 11 return 104 case 13 return 36 case 14 return 19 case 15 return 28 case 18 return 32 case 19 return 28 case 22 return 34 case 25 return 19 case 26 return 12 case 27 return 47 case 28 return 40 case 29 return 47 case 30 return 12 case 31 return 12 case 32 return 20 case 33 return 12 case 34 return 37 case 35 return 42 case 39 return 58 case 40 return 13 default return () },
    function($c) { if(97 le $c and $c le 122) then (9) else (), if(65 le $c and $c le 90) then (9) else () },
    ()),
  p:state(106,(),
    function($c) { switch($c) case 0 return 107 case 1 return 106 case 5 return 31 default return () },
    function($c) { () },
    ()),
  p:state(107,("\t","\n","\r"," ","."),
    function($c) { switch($c) case 41 return 7 default return () },
    function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 46 return (23) default return () },
    ()),
  p:state(108,("[a-z]","[A-Z]"),
    function($c) { switch($c) case 0 return 21 case 1 return 108 case 39 return 5 case 40 return 13 default return () },
    function($c) { if(97 le $c and $c le 122) then (9) else (), if(65 le $c and $c le 90) then (9) else () },
    ()));
declare %private variable $x:parser := p:make-parser($x:states);
declare function x:parse($s) { $x:parser($s) };
