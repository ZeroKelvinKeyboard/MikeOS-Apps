rem GREP.BAS - commandline file search tool
rem Copyright (C) Joshua Beck 2012
rem Licenced under the GNU General Public Licence v3
rem Version 1.1.0
rem Email: mikeosdeveloper@gmail.com

rem >>> check the input is valid <<<
if $1 = "" then goto help
if $1 = " " then goto help
case upper $1
if $1 = "HELP" then goto help


rem >>> collect filename (the first word ending in a space) <<<
x = 1
do
  string get $1 x v
  if v = 0 then goto notenoughpara
  if v = 32 then v = 0
  string set $2 x v
  x = x + 1
loop until v = 0

rem >>> collect search string (the rest of the line) <<<
y = 1
do
  string get $1 x v
  string set $3 y v
  x = x + 1
  y = y + 1
loop until v = 0

rem >>> access file
x = ramstart
load $2 x
if r = 1 then goto nofile
if s = 0 then goto blankfile

rem >>> data: column, data address, matches found, line, string length <<<
c = 1
d = x
f = 0
l = 1
len $3 z
y = z

rem >>> search loop <<<
do
  rem >>> load string from current location with same length as search <<<
  e = d
  for x = 1 to z
    peek v e
    string set $4 x v
    e = e + 1
  next x
  x = x + 1
  v = 0
  string set $4 x v
  case upper $4

  if $4 = $3 then gosub match
  
  rem >>> Move pointer forward <<<
  peek v d
  c = c + 1
  if v = 10 then l = l + 1
  if v = 10 then c = 1
  d = d + 1
  s = s - 1
loop until s < z 

rem F is set to 1 on a match
if f = 0 then print "There were no matches found"
end

match:
  rem >>> Mark at least one match was found <<<
  f = 1
  
  rem >>> Find the start of the line <<<
  x = d
  w = ramstart
  do
    x = x - 1
    peek v x
    if x < w then x = w
    if x = w then v = 10
  loop until v = 10
  if x > w then x = x + 1


  rem >>> Find the end <<<
  u = e
  q = s
  do
    peek v u
    u = u + 1
    if q = 0 then v = 10
    q = q - 1
  loop until v = 10
  u = u - 1
  if q > 0 then u = u - 1

  rem >>> Print the line with the search text in red <<<
  for r = x to u
    peek v r
    ink 4
    if r < d then ink 7
    if r > e then ink 7
    print chr v ;
  next r

  rem >>> Print position in yellow <<<
  ink 14
  $5 = " Line " + L + " Column " + C
  print $5
return  
  
help:
  print "GREP - file search utility"
  print "Copyright (C) Joshua Beck, 2012"
  print "Licenced under the GNU General Public Licence v3"
  print "Email: mikeosdeveloper@gmail.com"
  print ""
  print "Syntax: GREP filename string"
  print ""
end

notenoughpara:
  print "Not enough parameters"
end

nofile:
  print "File does not exist"
end

blankfile:
  print "File is blank"
end
