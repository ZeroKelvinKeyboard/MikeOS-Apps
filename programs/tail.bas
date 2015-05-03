rem Read the end of files.
rem Copyright (C) Joshua Beck, 2012
rem Email: mikeosdeveloper@gmail.com
rem Licenced under GNU GPLv3
rem Version 1.0.1

case upper $1
if $1 = "" then goto help
if $1 = "HELP" then goto help
y = & $1
v = & $2
w = & $3
filename:
  peek z y
  if z = 32 then goto inv-ext
  if z = 0 then goto inv-ext
  if z = '.' then goto proc-ext
  poke z v
  y = y + 1
  v = v + 1
goto filename

proc-ext:
  for x = 1 to 4
    peek z y
    poke z v
    poke z w
    y = y + 1
    v = v + 1
    w = w + 1
  next x
  if $3 = ".BAS" then goto valid-ext
  if $3 = ".TXT" then goto valid-ext

inv-ext:
  print "Can only print plain text files! (.BAS or .TXT)"
end

valid-ext:
  y = y + 1
  peek z y
  if z > 57 then goto nonumber
  if z < 48 then goto nonumber
  z = z - 48
  l = z
  y = y + 1
  peek v y
  if v < 48 then goto numdone
  if v > 57 then goto numdone
  v = v - 48
  z = z * 10
  z = z + v
  l = z
  goto numdone
  nonumber:
  l = 10
  numdone:
  load $1 40000
  s = s + 40000
  y = s
  l = l + 1
  if r = 0 then goto locstart
  print "File does not exist!"
end

locstart:
  if y < 40001 then goto printfile
  if l = 0 then y = y + 2
  if l = 0 then goto printfile
  peek z y
  if z = 10 then l = l - 1
  y = y - 1
goto locstart

printfile:
  if y > s then end
  peek z y
  if z = 0 then end
  if z = 10 then print ""
  if z > 31 then print chr z ;
  y = y + 1
goto printfile

help:
  print "Tail: Read the end of a file."
  print "Copyright (C) Joshua Beck, 2012"
  print "Email: mikeosdeveloper@gmail.com"
  print "Licenced under the GNU General Public Licence v3"
  print "Syntax: tail filename [lines]"
  print "Defaults to ten lines."
  print ""
end
