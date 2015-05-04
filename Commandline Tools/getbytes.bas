y = & $1
for x = 1 to 128
  peek z y
  if z > 96 and z < 123 then z = z - 32
  poke z y
  y = y + 1
next x
if $1 = "" then goto help
if $1 = "HELP" then goto help
y = & $1

peek z y
if z = '-' then gosub parameter
for t = 1 to 2
  v = 0
  x = 0
  text2num:
    peek z y
    y = y + 1
    x = x + 1
    if z < 48 then goto numdone
    if z > 57 then goto numdone
    v = v * 10
    z = z - 48
    v = v + z
  if x < 6 then goto text2num
  numdone:
  if t = 1 then a = v
  if t = 2 then b = v
next t
cursor off
b = b + 1
multi:
  if f = 0 and c = 0 then print "  " ;
  peek z a
  if f = 0 then print hex z ;
  if f = 1 and z = 10 then print ""
  if f = 1 and z = 10 then goto printd
  if f = 1 then print chr z ;
  if f = 0 then print " ";
  printd:
  a = a + 1
  c = c + 1
  if c = 26 then c = 0
  if b > a then goto multi
  if b < a then goto multi
print ""
cursor on
end

help:
  print ""
  print "GetBytes: Command line memory reading utility."
  print "Copyright (C) Joshua Beck, 2012"
  print "Licenced under GNU GPLv3."
  print ""
  print "getbytes {-a} [start] [stop]"
  print "Options:"
  print "'-a' = Print data in ASCII format (default Hexdecimal)"
  print "Displays memory bytes in range in a specified format."
  print ""
end

parameter:
  y = y + 1
  peek z y
  if z = 'A' then f = 1
  y = y + 2
return
