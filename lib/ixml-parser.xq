xquery version "3.0";
module namespace x = "http://snelson.org.uk/functions/ixml-parser";
import module namespace p = 'http://snelson.org.uk/functions/parser-runtime' at '../parser-runtime-ml.xq';
declare %private function x:ref($s) { function() { $s } };
declare %private variable $x:nt-names := ("<epsilon>","<ws>","ixml","ixml_1","rule","rule_2","rule_1","definition","definition_1","definition_1_1","alternative","alternative_1","alternative_1_1","term","repetition","one-or-more","one-or-more_3","one-or-more_2","one-or-more_1","zero-or-more","zero-or-more_3","zero-or-more_2","zero-or-more_1","separator","symbol","terminal","explicit-terminal","explicit-terminal_1","implicit-terminal","nonterminal","refinement","refinement_1","attribute","attribute_1","string","string_3","string_2","string_1","name","name_1","S");
declare %private variable $x:nt-edges := (
  function($c) { switch($c) case 0 return 1 case 1 return 0 case 3 return 2 default return () },
  function($c) { switch($c) case 1 return 8 case 3 return 73 case 4 return 79 case 38 return 5 case 39 return 13 case 40 return 7 default return () },
  function($c) { switch($c) case 0 return 3 case 1 return 2 default return () },
  function($c) { switch($c) case 40 return 7 default return () },
  function($c) { () },
  function($c) { switch($c) case 0 return 6 case 1 return 5 case 6 return 10 default return () },
  function($c) { switch($c) case 40 return 7 default return () },
  function($c) { () },
  function($c) { switch($c) case 0 return 1 case 1 return 8 case 3 return 73 case 4 return 79 case 38 return 5 case 39 return 13 default return () },
  function($c) { switch($c) case 0 return 3 case 1 return 9 default return () },
  function($c) { switch($c) case 0 return 11 case 1 return 10 case 5 return 31 case 7 return 106 default return () },
  function($c) { switch($c) case 1 return 38 case 8 return 14 case 9 return 16 case 10 return 18 case 11 return 48 case 13 return 36 case 14 return 19 case 15 return 28 case 18 return 32 case 19 return 28 case 22 return 34 case 24 return 19 case 25 return 12 case 26 return 47 case 27 return 40 case 28 return 47 case 29 return 12 case 30 return 12 case 31 return 20 case 32 return 12 case 33 return 37 case 34 return 42 case 37 return 50 case 38 return 58 case 39 return 13 case 40 return 7 default return () },
  function($c) { switch($c) case 0 return 3 case 1 return 12 default return () },
  function($c) { switch($c) case 0 return 3 case 1 return 13 default return () },
  function($c) { switch($c) case 0 return 15 case 1 return 14 case 9 return 16 default return () },
  function($c) { switch($c) case 40 return 7 default return () },
  function($c) { switch($c) case 0 return 17 case 1 return 16 case 10 return 18 default return () },
  function($c) { switch($c) case 1 return 102 case 11 return 48 case 13 return 36 case 14 return 19 case 15 return 28 case 18 return 32 case 19 return 28 case 22 return 34 case 24 return 19 case 25 return 12 case 26 return 47 case 27 return 40 case 28 return 47 case 29 return 12 case 30 return 12 case 31 return 20 case 32 return 12 case 33 return 37 case 34 return 42 case 37 return 50 case 38 return 58 case 39 return 13 case 40 return 7 default return () },
  function($c) { switch($c) case 0 return 3 case 1 return 18 default return () },
  function($c) { switch($c) case 0 return 3 case 1 return 19 default return () },
  function($c) { switch($c) case 0 return 21 case 1 return 20 case 38 return 30 default return () },
  function($c) { switch($c) case 1 return 25 case 39 return 13 case 40 return 7 default return () },
  function($c) { () },
  function($c) { () },
  function($c) { () },
  function($c) { switch($c) case 0 return 26 case 1 return 25 case 39 return 13 default return () },
  function($c) { switch($c) case 1 return 60 case 39 return 68 case 40 return 7 default return () },
  function($c) { () },
  function($c) { switch($c) case 0 return 3 case 1 return 28 default return () },
  function($c) { () },
  function($c) { switch($c) case 0 return 3 case 1 return 30 default return () },
  function($c) { switch($c) case 0 return 3 case 1 return 31 default return () },
  function($c) { switch($c) case 0 return 33 case 1 return 32 case 7 return 63 case 17 return 66 default return () },
  function($c) { switch($c) case 1 return 38 case 8 return 14 case 9 return 16 case 10 return 18 case 11 return 48 case 13 return 36 case 14 return 19 case 15 return 28 case 18 return 32 case 19 return 28 case 22 return 34 case 24 return 19 case 25 return 12 case 26 return 47 case 27 return 40 case 28 return 47 case 29 return 12 case 30 return 12 case 31 return 20 case 32 return 12 case 33 return 37 case 34 return 42 case 37 return 50 case 38 return 58 case 39 return 13 case 40 return 7 default return () },
  function($c) { switch($c) case 0 return 35 case 1 return 34 case 7 return 45 case 21 return 88 default return () },
  function($c) { switch($c) case 1 return 38 case 8 return 14 case 9 return 16 case 10 return 18 case 11 return 48 case 13 return 36 case 14 return 19 case 15 return 28 case 18 return 32 case 19 return 28 case 22 return 34 case 24 return 19 case 25 return 12 case 26 return 47 case 27 return 40 case 28 return 47 case 29 return 12 case 30 return 12 case 31 return 20 case 32 return 12 case 33 return 37 case 34 return 42 case 37 return 50 case 38 return 58 case 39 return 13 case 40 return 7 default return () },
  function($c) { switch($c) case 0 return 3 case 1 return 36 default return () },
  function($c) { switch($c) case 0 return 21 case 1 return 37 case 38 return 87 default return () },
  function($c) { switch($c) case 0 return 39 case 1 return 38 case 8 return 14 case 9 return 16 case 10 return 18 case 11 return 48 case 13 return 36 case 14 return 19 case 15 return 28 case 18 return 32 case 19 return 28 case 22 return 34 case 24 return 19 case 25 return 12 case 26 return 47 case 27 return 40 case 28 return 47 case 29 return 12 case 30 return 12 case 31 return 20 case 32 return 12 case 33 return 37 case 34 return 42 case 38 return 58 case 39 return 13 default return () },
  function($c) { switch($c) case 1 return 59 case 8 return 80 case 9 return 16 case 10 return 18 case 11 return 48 case 13 return 36 case 14 return 19 case 15 return 28 case 18 return 32 case 19 return 28 case 22 return 34 case 24 return 19 case 25 return 12 case 26 return 47 case 27 return 40 case 28 return 47 case 29 return 12 case 30 return 12 case 31 return 20 case 32 return 12 case 33 return 37 case 34 return 42 case 37 return 50 case 38 return 58 case 39 return 13 case 40 return 7 default return () },
  function($c) { switch($c) case 0 return 41 case 1 return 40 case 34 return 53 default return () },
  function($c) { switch($c) case 37 return 50 case 40 return 7 default return () },
  function($c) { switch($c) case 0 return 3 case 1 return 42 default return () },
  function($c) { () },
  function($c) { () },
  function($c) { switch($c) case 0 return 46 case 1 return 45 case 21 return 88 default return () },
  function($c) { switch($c) case 40 return 7 default return () },
  function($c) { switch($c) case 0 return 3 case 1 return 47 default return () },
  function($c) { switch($c) case 0 return 49 case 1 return 48 case 12 return 94 default return () },
  function($c) { switch($c) case 40 return 7 default return () },
  function($c) { switch($c) case 0 return 51 case 35 return 55 case 36 return 61 default return () },
  function($c) { switch($c) case 36 return 56 default return () },
  function($c) { () },
  function($c) { switch($c) case 0 return 3 case 1 return 53 default return () },
  function($c) { () },
  function($c) { () },
  function($c) { () },
  function($c) { () },
  function($c) { switch($c) case 0 return 3 case 1 return 58 default return () },
  function($c) { switch($c) case 0 return 39 case 1 return 59 case 8 return 80 case 9 return 16 case 10 return 18 case 11 return 48 case 13 return 36 case 14 return 19 case 15 return 28 case 18 return 32 case 19 return 28 case 22 return 34 case 24 return 19 case 25 return 12 case 26 return 47 case 27 return 40 case 28 return 47 case 29 return 12 case 30 return 12 case 31 return 20 case 32 return 12 case 33 return 37 case 34 return 42 case 38 return 58 case 39 return 13 default return () },
  function($c) { switch($c) case 0 return 26 case 1 return 60 case 39 return 68 default return () },
  function($c) { switch($c) case 0 return 62 case 35 return 55 default return () },
  function($c) { () },
  function($c) { switch($c) case 0 return 64 case 1 return 63 case 17 return 66 default return () },
  function($c) { switch($c) case 40 return 7 default return () },
  function($c) { () },
  function($c) { switch($c) case 0 return 67 case 1 return 66 case 16 return 69 default return () },
  function($c) { switch($c) case 40 return 7 default return () },
  function($c) { switch($c) case 0 return 3 case 1 return 68 default return () },
  function($c) { switch($c) case 0 return 70 case 1 return 69 case 23 return 71 default return () },
  function($c) { switch($c) case 1 return 75 case 24 return 93 case 25 return 12 case 26 return 47 case 27 return 40 case 28 return 47 case 29 return 12 case 30 return 12 case 31 return 20 case 32 return 12 case 33 return 37 case 34 return 42 case 37 return 50 case 38 return 58 case 39 return 13 case 40 return 7 default return () },
  function($c) { switch($c) case 0 return 3 case 1 return 71 default return () },
  function($c) { () },
  function($c) { switch($c) case 0 return 74 case 1 return 73 case 4 return 79 default return () },
  function($c) { switch($c) case 1 return 108 case 38 return 5 case 39 return 13 case 40 return 7 default return () },
  function($c) { switch($c) case 0 return 76 case 1 return 75 case 24 return 93 case 25 return 12 case 26 return 47 case 27 return 40 case 28 return 47 case 29 return 12 case 30 return 12 case 31 return 20 case 32 return 12 case 33 return 37 case 34 return 42 case 38 return 58 case 39 return 13 default return () },
  function($c) { switch($c) case 1 return 81 case 25 return 12 case 26 return 47 case 27 return 40 case 28 return 47 case 29 return 12 case 30 return 12 case 31 return 20 case 32 return 12 case 33 return 37 case 34 return 42 case 37 return 50 case 38 return 58 case 39 return 13 case 40 return 7 default return () },
  function($c) { () },
  function($c) { () },
  function($c) { switch($c) case 0 return 3 case 1 return 79 default return () },
  function($c) { switch($c) case 0 return 15 case 1 return 80 case 9 return 16 default return () },
  function($c) { switch($c) case 0 return 82 case 1 return 81 case 25 return 12 case 26 return 47 case 27 return 40 case 28 return 47 case 29 return 12 case 30 return 12 case 31 return 20 case 32 return 12 case 33 return 37 case 34 return 42 case 38 return 58 case 39 return 13 default return () },
  function($c) { switch($c) case 1 return 83 case 26 return 47 case 27 return 40 case 28 return 47 case 31 return 20 case 33 return 37 case 34 return 42 case 37 return 50 case 38 return 58 case 39 return 13 case 40 return 7 default return () },
  function($c) { switch($c) case 0 return 84 case 1 return 83 case 26 return 47 case 27 return 40 case 28 return 47 case 31 return 20 case 33 return 37 case 34 return 42 case 38 return 58 case 39 return 13 default return () },
  function($c) { switch($c) case 1 return 85 case 27 return 40 case 34 return 42 case 37 return 50 case 39 return 13 case 40 return 7 default return () },
  function($c) { switch($c) case 0 return 86 case 1 return 85 case 27 return 40 case 34 return 42 case 39 return 13 default return () },
  function($c) { switch($c) case 1 return 60 case 37 return 50 case 39 return 68 case 40 return 7 default return () },
  function($c) { switch($c) case 0 return 3 case 1 return 87 default return () },
  function($c) { switch($c) case 0 return 89 case 1 return 88 case 20 return 91 default return () },
  function($c) { switch($c) case 40 return 7 default return () },
  function($c) { () },
  function($c) { switch($c) case 0 return 70 case 1 return 91 case 23 return 92 default return () },
  function($c) { switch($c) case 0 return 3 case 1 return 92 default return () },
  function($c) { switch($c) case 0 return 3 case 1 return 93 default return () },
  function($c) { switch($c) case 0 return 95 case 1 return 94 case 13 return 36 default return () },
  function($c) { switch($c) case 1 return 96 case 14 return 19 case 15 return 28 case 18 return 32 case 19 return 28 case 22 return 34 case 24 return 19 case 25 return 12 case 26 return 47 case 27 return 40 case 28 return 47 case 29 return 12 case 30 return 12 case 31 return 20 case 32 return 12 case 33 return 37 case 34 return 42 case 37 return 50 case 38 return 58 case 39 return 13 case 40 return 7 default return () },
  function($c) { switch($c) case 0 return 97 case 1 return 96 case 14 return 19 case 15 return 28 case 18 return 32 case 19 return 28 case 22 return 34 case 24 return 19 case 25 return 12 case 26 return 47 case 27 return 40 case 28 return 47 case 29 return 12 case 30 return 12 case 31 return 20 case 32 return 12 case 33 return 37 case 34 return 42 case 38 return 58 case 39 return 13 default return () },
  function($c) { switch($c) case 1 return 98 case 15 return 28 case 18 return 32 case 19 return 28 case 22 return 34 case 25 return 12 case 26 return 47 case 27 return 40 case 28 return 47 case 29 return 12 case 30 return 12 case 31 return 20 case 32 return 12 case 33 return 37 case 34 return 42 case 37 return 50 case 38 return 58 case 39 return 13 case 40 return 7 default return () },
  function($c) { switch($c) case 0 return 99 case 1 return 98 case 15 return 28 case 18 return 32 case 19 return 28 case 22 return 34 case 25 return 12 case 26 return 47 case 27 return 40 case 28 return 47 case 29 return 12 case 30 return 12 case 31 return 20 case 32 return 12 case 33 return 37 case 34 return 42 case 38 return 58 case 39 return 13 default return () },
  function($c) { switch($c) case 1 return 100 case 18 return 32 case 22 return 34 case 26 return 47 case 27 return 40 case 28 return 47 case 31 return 20 case 33 return 37 case 34 return 42 case 37 return 50 case 38 return 58 case 39 return 13 case 40 return 7 default return () },
  function($c) { switch($c) case 0 return 101 case 1 return 100 case 18 return 32 case 22 return 34 case 26 return 47 case 27 return 40 case 28 return 47 case 31 return 20 case 33 return 37 case 34 return 42 case 38 return 58 case 39 return 13 default return () },
  function($c) { switch($c) case 1 return 85 case 27 return 40 case 34 return 42 case 37 return 50 case 39 return 13 case 40 return 7 default return () },
  function($c) { switch($c) case 0 return 103 case 1 return 102 case 11 return 48 case 13 return 36 case 14 return 19 case 15 return 28 case 18 return 32 case 19 return 28 case 22 return 34 case 24 return 19 case 25 return 12 case 26 return 47 case 27 return 40 case 28 return 47 case 29 return 12 case 30 return 12 case 31 return 20 case 32 return 12 case 33 return 37 case 34 return 42 case 38 return 58 case 39 return 13 default return () },
  function($c) { switch($c) case 1 return 105 case 11 return 104 case 13 return 36 case 14 return 19 case 15 return 28 case 18 return 32 case 19 return 28 case 22 return 34 case 24 return 19 case 25 return 12 case 26 return 47 case 27 return 40 case 28 return 47 case 29 return 12 case 30 return 12 case 31 return 20 case 32 return 12 case 33 return 37 case 34 return 42 case 37 return 50 case 38 return 58 case 39 return 13 case 40 return 7 default return () },
  function($c) { switch($c) case 0 return 49 case 1 return 104 case 12 return 94 default return () },
  function($c) { switch($c) case 0 return 103 case 1 return 105 case 11 return 104 case 13 return 36 case 14 return 19 case 15 return 28 case 18 return 32 case 19 return 28 case 22 return 34 case 24 return 19 case 25 return 12 case 26 return 47 case 27 return 40 case 28 return 47 case 29 return 12 case 30 return 12 case 31 return 20 case 32 return 12 case 33 return 37 case 34 return 42 case 38 return 58 case 39 return 13 default return () },
  function($c) { switch($c) case 0 return 107 case 1 return 106 case 5 return 31 default return () },
  function($c) { switch($c) case 40 return 7 default return () },
  function($c) { switch($c) case 0 return 21 case 1 return 108 case 38 return 5 case 39 return 13 default return () });
declare %private variable $x:t-edges := (
  function($c) { () },
  function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) default return (),  if(97 le $c and $c le 122) then (9) else (), if(65 le $c and $c le 90) then (9) else () },
  function($c) { () },
  function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) default return () },
  function($c) { () },
  function($c) { () },
  function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 58 return (78) default return () },
  function($c) { () },
  function($c) { if(97 le $c and $c le 122) then (9) else (), if(65 le $c and $c le 90) then (9) else () },
  function($c) { () },
  function($c) { () },
  function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 34 return (43) case 40 return (29) case 43 return (27) case 45 return (24) case 46 return (23) case 59 return (22) case 64 return (44) default return (),  if(65 le $c and $c le 90) then (9) else (), if(97 le $c and $c le 122) then (9) else () },
  function($c) { () },
  function($c) { if(97 le $c and $c le 122) then (9) else (), if(65 le $c and $c le 90) then (9) else () },
  function($c) { () },
  function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 59 return (22) default return () },
  function($c) { () },
  function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 34 return (43) case 40 return (29) case 43 return (27) case 45 return (24) case 64 return (44) default return (),  if(65 le $c and $c le 90) then (9) else (), if(97 le $c and $c le 122) then (9) else () },
  function($c) { () },
  function($c) { () },
  function($c) { () },
  function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) default return (),  if(65 le $c and $c le 90) then (9) else (), if(97 le $c and $c le 122) then (9) else () },
  function($c) { () },
  function($c) { () },
  function($c) { () },
  function($c) { if(65 le $c and $c le 90) then (9) else (), if(97 le $c and $c le 122) then (9) else () },
  function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) default return (),  if(65 le $c and $c le 90) then (9) else (), if(97 le $c and $c le 122) then (9) else () },
  function($c) { () },
  function($c) { () },
  function($c) { () },
  function($c) { () },
  function($c) { () },
  function($c) { () },
  function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 34 return (43) case 40 return (29) case 41 return (65) case 43 return (27) case 45 return (24) case 59 return (22) case 64 return (44) default return (),  if(65 le $c and $c le 90) then (9) else (), if(97 le $c and $c le 122) then (9) else () },
  function($c) { () },
  function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 34 return (43) case 40 return (29) case 41 return (77) case 43 return (27) case 45 return (24) case 59 return (22) case 64 return (44) default return (),  if(65 le $c and $c le 90) then (9) else (), if(97 le $c and $c le 122) then (9) else () },
  function($c) { () },
  function($c) { () },
  function($c) { if(65 le $c and $c le 90) then (9) else (), if(97 le $c and $c le 122) then (9) else () },
  function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 34 return (43) case 40 return (29) case 43 return (27) case 45 return (24) case 59 return (22) case 64 return (44) default return (),  if(65 le $c and $c le 90) then (9) else (), if(97 le $c and $c le 122) then (9) else () },
  function($c) { () },
  function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 34 return (43) default return () },
  function($c) { () },
  function($c) { () },
  function($c) { () },
  function($c) { () },
  function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 41 return (77) default return () },
  function($c) { () },
  function($c) { () },
  function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 44 return (54) default return () },
  function($c) { () },
  function($c) { switch($c) case 34 return (57) default return (),  if(9 le $c and $c le 127) then (52) else () },
  function($c) { () },
  function($c) { () },
  function($c) { () },
  function($c) { () },
  function($c) { if(9 le $c and $c le 127) then (52) else () },
  function($c) { () },
  function($c) { () },
  function($c) { if(97 le $c and $c le 122) then (9) else (), if(65 le $c and $c le 90) then (9) else () },
  function($c) { if(97 le $c and $c le 122) then (9) else (), if(65 le $c and $c le 90) then (9) else () },
  function($c) { () },
  function($c) { switch($c) case 34 return (57) default return () },
  function($c) { () },
  function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 41 return (65) default return () },
  function($c) { () },
  function($c) { () },
  function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 43 return (72) default return () },
  function($c) { if(65 le $c and $c le 90) then (9) else (), if(97 le $c and $c le 122) then (9) else () },
  function($c) { () },
  function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 34 return (43) case 43 return (27) case 45 return (24) case 64 return (44) default return (),  if(65 le $c and $c le 90) then (9) else (), if(97 le $c and $c le 122) then (9) else () },
  function($c) { () },
  function($c) { () },
  function($c) { () },
  function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) default return (),  if(65 le $c and $c le 90) then (9) else (), if(97 le $c and $c le 122) then (9) else () },
  function($c) { if(65 le $c and $c le 90) then (9) else (), if(97 le $c and $c le 122) then (9) else () },
  function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 34 return (43) case 43 return (27) case 45 return (24) case 64 return (44) default return (),  if(65 le $c and $c le 90) then (9) else (), if(97 le $c and $c le 122) then (9) else () },
  function($c) { () },
  function($c) { () },
  function($c) { () },
  function($c) { () },
  function($c) { if(97 le $c and $c le 122) then (9) else (), if(65 le $c and $c le 90) then (9) else () },
  function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 34 return (43) case 43 return (27) case 45 return (24) case 64 return (44) default return (),  if(97 le $c and $c le 122) then (9) else (), if(65 le $c and $c le 90) then (9) else () },
  function($c) { if(65 le $c and $c le 90) then (9) else (), if(97 le $c and $c le 122) then (9) else () },
  function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 34 return (43) case 43 return (27) case 45 return (24) case 64 return (44) default return (),  if(97 le $c and $c le 122) then (9) else (), if(65 le $c and $c le 90) then (9) else () },
  function($c) { if(65 le $c and $c le 90) then (9) else (), if(97 le $c and $c le 122) then (9) else () },
  function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 34 return (43) case 43 return (27) default return (),  if(65 le $c and $c le 90) then (9) else (), if(97 le $c and $c le 122) then (9) else () },
  function($c) { () },
  function($c) { () },
  function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 42 return (90) default return () },
  function($c) { () },
  function($c) { () },
  function($c) { () },
  function($c) { () },
  function($c) { () },
  function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 34 return (43) case 40 return (29) case 43 return (27) case 45 return (24) case 64 return (44) default return (),  if(65 le $c and $c le 90) then (9) else (), if(97 le $c and $c le 122) then (9) else () },
  function($c) { if(97 le $c and $c le 122) then (9) else (), if(65 le $c and $c le 90) then (9) else () },
  function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 34 return (43) case 40 return (29) case 43 return (27) case 45 return (24) case 64 return (44) default return (),  if(97 le $c and $c le 122) then (9) else (), if(65 le $c and $c le 90) then (9) else () },
  function($c) { if(65 le $c and $c le 90) then (9) else (), if(97 le $c and $c le 122) then (9) else () },
  function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 34 return (43) case 40 return (29) case 43 return (27) case 45 return (24) case 64 return (44) default return (),  if(97 le $c and $c le 122) then (9) else (), if(65 le $c and $c le 90) then (9) else () },
  function($c) { if(97 le $c and $c le 122) then (9) else (), if(65 le $c and $c le 90) then (9) else () },
  function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 34 return (43) case 40 return (29) case 43 return (27) case 45 return (24) case 64 return (44) default return (),  if(97 le $c and $c le 122) then (9) else (), if(65 le $c and $c le 90) then (9) else () },
  function($c) { if(97 le $c and $c le 122) then (9) else (), if(65 le $c and $c le 90) then (9) else () },
  function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 34 return (43) case 40 return (29) case 43 return (27) case 45 return (24) case 64 return (44) default return (),  if(65 le $c and $c le 90) then (9) else (), if(97 le $c and $c le 122) then (9) else () },
  function($c) { () },
  function($c) { if(97 le $c and $c le 122) then (9) else (), if(65 le $c and $c le 90) then (9) else () },
  function($c) { () },
  function($c) { switch($c) case 9 return (4) case 10 return (4) case 13 return (4) case 32 return (4) case 46 return (23) default return () },
  function($c) { if(97 le $c and $c le 122) then (9) else (), if(65 le $c and $c le 90) then (9) else () });
declare %private variable $x:t-values := (
  x:ref(()),
  x:ref(("\t","\n","\r"," ","[a-z]","[A-Z]")),
  x:ref(()),
  x:ref(("\t","\n","\r"," ")),
  x:ref(()),
  x:ref(()),
  x:ref(("\t","\n","\r"," ",":")),
  x:ref(()),
  x:ref(("[a-z]","[A-Z]")),
  x:ref(()),
  x:ref(()),
  x:ref(("\t","\n","\r"," ","\&quot;","(","+","-",".",";","@","[A-Z]","[a-z]")),
  x:ref(()),
  x:ref(("[a-z]","[A-Z]")),
  x:ref(()),
  x:ref(("\t","\n","\r"," ",";")),
  x:ref(()),
  x:ref(("\t","\n","\r"," ","\&quot;","(","+","-","@","[A-Z]","[a-z]")),
  x:ref(()),
  x:ref(()),
  x:ref(()),
  x:ref(("\t","\n","\r"," ","[A-Z]","[a-z]")),
  x:ref(()),
  x:ref(()),
  x:ref(()),
  x:ref(("[A-Z]","[a-z]")),
  x:ref(("\t","\n","\r"," ","[A-Z]","[a-z]")),
  x:ref(()),
  x:ref(()),
  x:ref(()),
  x:ref(()),
  x:ref(()),
  x:ref(()),
  x:ref(("\t","\n","\r"," ","\&quot;","(",")","+","-",";","@","[A-Z]","[a-z]")),
  x:ref(()),
  x:ref(("\t","\n","\r"," ","\&quot;","(",")","+","-",";","@","[A-Z]","[a-z]")),
  x:ref(()),
  x:ref(()),
  x:ref(("[A-Z]","[a-z]")),
  x:ref(("\t","\n","\r"," ","\&quot;","(","+","-",";","@","[A-Z]","[a-z]")),
  x:ref(()),
  x:ref(("\t","\n","\r"," ","\&quot;")),
  x:ref(()),
  x:ref(()),
  x:ref(()),
  x:ref(()),
  x:ref(("\t","\n","\r"," ",")")),
  x:ref(()),
  x:ref(()),
  x:ref(("\t","\n","\r"," ",",")),
  x:ref(()),
  x:ref(("\&quot;","[\t-]")),
  x:ref(()),
  x:ref(()),
  x:ref(()),
  x:ref(()),
  x:ref(("[\t-]")),
  x:ref(()),
  x:ref(()),
  x:ref(("[a-z]","[A-Z]")),
  x:ref(("[a-z]","[A-Z]")),
  x:ref(()),
  x:ref(("\&quot;")),
  x:ref(()),
  x:ref(("\t","\n","\r"," ",")")),
  x:ref(()),
  x:ref(()),
  x:ref(("\t","\n","\r"," ","+")),
  x:ref(("[A-Z]","[a-z]")),
  x:ref(()),
  x:ref(("\t","\n","\r"," ","\&quot;","+","-","@","[A-Z]","[a-z]")),
  x:ref(()),
  x:ref(()),
  x:ref(()),
  x:ref(("\t","\n","\r"," ","[A-Z]","[a-z]")),
  x:ref(("[A-Z]","[a-z]")),
  x:ref(("\t","\n","\r"," ","\&quot;","+","-","@","[A-Z]","[a-z]")),
  x:ref(()),
  x:ref(()),
  x:ref(()),
  x:ref(()),
  x:ref(("[a-z]","[A-Z]")),
  x:ref(("\t","\n","\r"," ","\&quot;","+","-","@","[a-z]","[A-Z]")),
  x:ref(("[A-Z]","[a-z]")),
  x:ref(("\t","\n","\r"," ","\&quot;","+","-","@","[a-z]","[A-Z]")),
  x:ref(("[A-Z]","[a-z]")),
  x:ref(("\t","\n","\r"," ","\&quot;","+","[A-Z]","[a-z]")),
  x:ref(()),
  x:ref(()),
  x:ref(("\t","\n","\r"," ","*")),
  x:ref(()),
  x:ref(()),
  x:ref(()),
  x:ref(()),
  x:ref(()),
  x:ref(("\t","\n","\r"," ","\&quot;","(","+","-","@","[A-Z]","[a-z]")),
  x:ref(("[a-z]","[A-Z]")),
  x:ref(("\t","\n","\r"," ","\&quot;","(","+","-","@","[a-z]","[A-Z]")),
  x:ref(("[A-Z]","[a-z]")),
  x:ref(("\t","\n","\r"," ","\&quot;","(","+","-","@","[a-z]","[A-Z]")),
  x:ref(("[a-z]","[A-Z]")),
  x:ref(("\t","\n","\r"," ","\&quot;","(","+","-","@","[a-z]","[A-Z]")),
  x:ref(("[a-z]","[A-Z]")),
  x:ref(("\t","\n","\r"," ","\&quot;","(","+","-","@","[A-Z]","[a-z]")),
  x:ref(()),
  x:ref(("[a-z]","[A-Z]")),
  x:ref(()),
  x:ref(("\t","\n","\r"," ",".")),
  x:ref(("[a-z]","[A-Z]")));
declare %private variable $x:complete := (
  x:ref(()),
  x:ref(()),
  x:ref((
    x:ref((2,function($ch) {
function() {
      element ixml { $ch ! (
        typeswitch(.)
        case xs:string return text { . }
        case xs:integer return text { fn:codepoints-to-string(.) }
        default return .()
      )}
    }
    })))),
  x:ref(()),
  x:ref((
    x:ref((40,function($ch) {
()
    })))),
  x:ref(()),
  x:ref(()),
  x:ref((
    x:ref((1,function($ch) {
()
    })))),
  x:ref(()),
  x:ref((
    x:ref((39,function($ch) {
function() { $ch ! (
     typeswitch(.)
     case xs:string return text { . }
     case xs:integer return text { fn:codepoints-to-string(.) }
     default return .()
   )}
    })))),
  x:ref(()),
  x:ref((
    x:ref((8,function($ch) {
function() { $ch ! (
     typeswitch(.)
     case xs:string return text { . }
     case xs:integer return text { fn:codepoints-to-string(.) }
     default return .()
   )}
    })),
    x:ref((10,function($ch) {
function() {
      element alternative { $ch ! (
        typeswitch(.)
        case xs:string return text { . }
        case xs:integer return text { fn:codepoints-to-string(.) }
        default return .()
      )}
    }
    })),
    x:ref((7,function($ch) {
function() { $ch ! (
     typeswitch(.)
     case xs:string return text { . }
     case xs:integer return text { fn:codepoints-to-string(.) }
     default return .()
   )}
    })))),
  x:ref((
    x:ref((24,function($ch) {
function() { $ch ! (
     typeswitch(.)
     case xs:string return text { . }
     case xs:integer return text { fn:codepoints-to-string(.) }
     default return .()
   )}
    })))),
  x:ref((
    x:ref((38,function($ch) {
function() {
      attribute name { fn:string-join($ch ! (
        typeswitch(.)
        case xs:string return .
        case xs:integer return fn:codepoints-to-string(.)
        default return .() ! fn:string(.)
      ))}
    }
    })))),
  x:ref((
    x:ref((7,function($ch) {
function() { $ch ! (
     typeswitch(.)
     case xs:string return text { . }
     case xs:integer return text { fn:codepoints-to-string(.) }
     default return .()
   )}
    })))),
  x:ref(()),
  x:ref((
    x:ref((8,function($ch) {
function() { $ch ! (
     typeswitch(.)
     case xs:string return text { . }
     case xs:integer return text { fn:codepoints-to-string(.) }
     default return .()
   )}
    })))),
  x:ref((
    x:ref((10,function($ch) {
function() {
      element alternative { $ch ! (
        typeswitch(.)
        case xs:string return text { . }
        case xs:integer return text { fn:codepoints-to-string(.) }
        default return .()
      )}
    }
    })))),
  x:ref((
    x:ref((8,function($ch) {
function() { $ch ! (
     typeswitch(.)
     case xs:string return text { . }
     case xs:integer return text { fn:codepoints-to-string(.) }
     default return .()
   )}
    })))),
  x:ref((
    x:ref((13,function($ch) {
function() {
      element term { $ch ! (
        typeswitch(.)
        case xs:string return text { . }
        case xs:integer return text { fn:codepoints-to-string(.) }
        default return .()
      )}
    }
    })))),
  x:ref(()),
  x:ref(()),
  x:ref((
    x:ref((9,function($ch) {
()
    })))),
  x:ref((
    x:ref((5,function($ch) {
()
    })))),
  x:ref((
    x:ref((31,function($ch) {
()
    })))),
  x:ref(()),
  x:ref(()),
  x:ref((
    x:ref((27,function($ch) {
()
    })))),
  x:ref((
    x:ref((14,function($ch) {
function() { $ch ! (
     typeswitch(.)
     case xs:string return text { . }
     case xs:integer return text { fn:codepoints-to-string(.) }
     default return .()
   )}
    })))),
  x:ref((
    x:ref((18,function($ch) {
()
    })),
    x:ref((22,function($ch) {
()
    })))),
  x:ref((
    x:ref((30,function($ch) {
function() {
      element refinement { $ch ! (
        typeswitch(.)
        case xs:string return text { . }
        case xs:integer return text { fn:codepoints-to-string(.) }
        default return .()
      )}
    }
    })))),
  x:ref((
    x:ref((4,function($ch) {
function() {
      element rule { $ch ! (
        typeswitch(.)
        case xs:string return text { . }
        case xs:integer return text { fn:codepoints-to-string(.) }
        default return .()
      )}
    }
    })))),
  x:ref(()),
  x:ref((
    x:ref((8,function($ch) {
function() { $ch ! (
     typeswitch(.)
     case xs:string return text { . }
     case xs:integer return text { fn:codepoints-to-string(.) }
     default return .()
   )}
    })),
    x:ref((10,function($ch) {
function() {
      element alternative { $ch ! (
        typeswitch(.)
        case xs:string return text { . }
        case xs:integer return text { fn:codepoints-to-string(.) }
        default return .()
      )}
    }
    })),
    x:ref((7,function($ch) {
function() { $ch ! (
     typeswitch(.)
     case xs:string return text { . }
     case xs:integer return text { fn:codepoints-to-string(.) }
     default return .()
   )}
    })))),
  x:ref(()),
  x:ref((
    x:ref((8,function($ch) {
function() { $ch ! (
     typeswitch(.)
     case xs:string return text { . }
     case xs:integer return text { fn:codepoints-to-string(.) }
     default return .()
   )}
    })),
    x:ref((10,function($ch) {
function() {
      element alternative { $ch ! (
        typeswitch(.)
        case xs:string return text { . }
        case xs:integer return text { fn:codepoints-to-string(.) }
        default return .()
      )}
    }
    })),
    x:ref((7,function($ch) {
function() { $ch ! (
     typeswitch(.)
     case xs:string return text { . }
     case xs:integer return text { fn:codepoints-to-string(.) }
     default return .()
   )}
    })))),
  x:ref((
    x:ref((11,function($ch) {
function() { $ch ! (
     typeswitch(.)
     case xs:string return text { . }
     case xs:integer return text { fn:codepoints-to-string(.) }
     default return .()
   )}
    })))),
  x:ref(()),
  x:ref((
    x:ref((8,function($ch) {
function() { $ch ! (
     typeswitch(.)
     case xs:string return text { . }
     case xs:integer return text { fn:codepoints-to-string(.) }
     default return .()
   )}
    })),
    x:ref((10,function($ch) {
function() {
      element alternative { $ch ! (
        typeswitch(.)
        case xs:string return text { . }
        case xs:integer return text { fn:codepoints-to-string(.) }
        default return .()
      )}
    }
    })),
    x:ref((7,function($ch) {
function() { $ch ! (
     typeswitch(.)
     case xs:string return text { . }
     case xs:integer return text { fn:codepoints-to-string(.) }
     default return .()
   )}
    })))),
  x:ref((
    x:ref((8,function($ch) {
function() { $ch ! (
     typeswitch(.)
     case xs:string return text { . }
     case xs:integer return text { fn:codepoints-to-string(.) }
     default return .()
   )}
    })),
    x:ref((10,function($ch) {
function() {
      element alternative { $ch ! (
        typeswitch(.)
        case xs:string return text { . }
        case xs:integer return text { fn:codepoints-to-string(.) }
        default return .()
      )}
    }
    })))),
  x:ref(()),
  x:ref(()),
  x:ref((
    x:ref((28,function($ch) {
function() {
      element implicit-terminal { $ch ! (
        typeswitch(.)
        case xs:string return text { . }
        case xs:integer return text { fn:codepoints-to-string(.) }
        default return .()
      )}
    }
    })))),
  x:ref((
    x:ref((37,function($ch) {
()
    })))),
  x:ref((
    x:ref((33,function($ch) {
()
    })))),
  x:ref(()),
  x:ref(()),
  x:ref((
    x:ref((25,function($ch) {
function() { $ch ! (
     typeswitch(.)
     case xs:string return text { . }
     case xs:integer return text { fn:codepoints-to-string(.) }
     default return .()
   )}
    })))),
  x:ref((
    x:ref((10,function($ch) {
function() {
      element alternative { $ch ! (
        typeswitch(.)
        case xs:string return text { . }
        case xs:integer return text { fn:codepoints-to-string(.) }
        default return .()
      )}
    }
    })))),
  x:ref(()),
  x:ref(()),
  x:ref((
    x:ref((36,function($ch) {
function() { $ch ! (
     typeswitch(.)
     case xs:string return text { . }
     case xs:integer return text { fn:codepoints-to-string(.) }
     default return .()
   )}
    })))),
  x:ref((
    x:ref((36,function($ch) {
function() { $ch ! (
     typeswitch(.)
     case xs:string return text { . }
     case xs:integer return text { fn:codepoints-to-string(.) }
     default return .()
   )}
    })))),
  x:ref((
    x:ref((26,function($ch) {
function() {
      element explicit-terminal { $ch ! (
        typeswitch(.)
        case xs:string return text { . }
        case xs:integer return text { fn:codepoints-to-string(.) }
        default return .()
      )}
    }
    })))),
  x:ref((
    x:ref((12,function($ch) {
()
    })))),
  x:ref((
    x:ref((34,function($ch) {
fn:string-join($ch ! (
        typeswitch(.)
        case xs:string return .
        case xs:integer return fn:codepoints-to-string(.)
        default return .()
      ))
    })))),
  x:ref(()),
  x:ref((
    x:ref((35,function($ch) {
()
    })))),
  x:ref((
    x:ref((29,function($ch) {
function() {
      element nonterminal { $ch ! (
        typeswitch(.)
        case xs:string return text { . }
        case xs:integer return text { fn:codepoints-to-string(.) }
        default return .()
      )}
    }
    })))),
  x:ref((
    x:ref((8,function($ch) {
function() { $ch ! (
     typeswitch(.)
     case xs:string return text { . }
     case xs:integer return text { fn:codepoints-to-string(.) }
     default return .()
   )}
    })),
    x:ref((10,function($ch) {
function() {
      element alternative { $ch ! (
        typeswitch(.)
        case xs:string return text { . }
        case xs:integer return text { fn:codepoints-to-string(.) }
        default return .()
      )}
    }
    })))),
  x:ref(()),
  x:ref(()),
  x:ref(()),
  x:ref(()),
  x:ref(()),
  x:ref((
    x:ref((17,function($ch) {
()
    })))),
  x:ref(()),
  x:ref(()),
  x:ref(()),
  x:ref((
    x:ref((15,function($ch) {
function() {
      element one-or-more { $ch ! (
        typeswitch(.)
        case xs:string return text { . }
        case xs:integer return text { fn:codepoints-to-string(.) }
        default return .()
      )}
    }
    })))),
  x:ref((
    x:ref((23,function($ch) {
function() {
      element separator { $ch ! (
        typeswitch(.)
        case xs:string return text { . }
        case xs:integer return text { fn:codepoints-to-string(.) }
        default return .()
      )}
    }
    })))),
  x:ref((
    x:ref((15,function($ch) {
function() {
      element one-or-more { $ch ! (
        typeswitch(.)
        case xs:string return text { . }
        case xs:integer return text { fn:codepoints-to-string(.) }
        default return .()
      )}
    }
    })))),
  x:ref((
    x:ref((16,function($ch) {
()
    })))),
  x:ref(()),
  x:ref(()),
  x:ref((
    x:ref((23,function($ch) {
function() {
      element separator { $ch ! (
        typeswitch(.)
        case xs:string return text { . }
        case xs:integer return text { fn:codepoints-to-string(.) }
        default return .()
      )}
    }
    })))),
  x:ref(()),
  x:ref((
    x:ref((21,function($ch) {
()
    })))),
  x:ref((
    x:ref((6,function($ch) {
()
    })))),
  x:ref((
    x:ref((3,function($ch) {
function() { $ch ! (
     typeswitch(.)
     case xs:string return text { . }
     case xs:integer return text { fn:codepoints-to-string(.) }
     default return .()
   )}
    })))),
  x:ref(()),
  x:ref(()),
  x:ref(()),
  x:ref(()),
  x:ref(()),
  x:ref(()),
  x:ref(()),
  x:ref((
    x:ref((32,function($ch) {
function() {
      element attribute { $ch ! (
        typeswitch(.)
        case xs:string return text { . }
        case xs:integer return text { fn:codepoints-to-string(.) }
        default return .()
      )}
    }
    })))),
  x:ref(()),
  x:ref(()),
  x:ref((
    x:ref((20,function($ch) {
()
    })))),
  x:ref((
    x:ref((19,function($ch) {
function() {
      element zero-or-more { $ch ! (
        typeswitch(.)
        case xs:string return text { . }
        case xs:integer return text { fn:codepoints-to-string(.) }
        default return .()
      )}
    }
    })))),
  x:ref((
    x:ref((19,function($ch) {
function() {
      element zero-or-more { $ch ! (
        typeswitch(.)
        case xs:string return text { . }
        case xs:integer return text { fn:codepoints-to-string(.) }
        default return .()
      )}
    }
    })))),
  x:ref((
    x:ref((23,function($ch) {
function() {
      element separator { $ch ! (
        typeswitch(.)
        case xs:string return text { . }
        case xs:integer return text { fn:codepoints-to-string(.) }
        default return .()
      )}
    }
    })))),
  x:ref(()),
  x:ref(()),
  x:ref(()),
  x:ref(()),
  x:ref(()),
  x:ref(()),
  x:ref(()),
  x:ref(()),
  x:ref((
    x:ref((10,function($ch) {
function() {
      element alternative { $ch ! (
        typeswitch(.)
        case xs:string return text { . }
        case xs:integer return text { fn:codepoints-to-string(.) }
        default return .()
      )}
    }
    })))),
  x:ref(()),
  x:ref(()),
  x:ref(()),
  x:ref(()),
  x:ref(()),
  x:ref(()));
declare %private variable $x:parser :=
  p:make-parser($x:nt-edges,$x:t-edges,$x:t-values,$x:complete,$x:nt-names);
declare function x:parse($s) { $x:parser($s) };
