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

for t = 1 to 2
  v = 0
  x = 0
  text2num:
    peek z y
    y = y + 1
    x = x + 1
    if z < 48 then goto done
    if z > 57 then goto done
    v = v * 10
    z = z - 48
    v = v + z
  if x < 5 then goto text2num
  done:
  if t = 1 then a = v
  if t = 2 then b = v
next t
cursor off
b = b + 1
multi:
  if c = 0 then print "  " ;
  peek z a
  print hex z ;
  print " ";
  a = a + 1
  c = c + 1
  if c = 26 then print ""
  if c = 26 then c = 0
if b > a then goto multi
if b < a then goto multi
print ""
cursor on
end

help:
  print ""
  print "GetBytes: Command line memory reading utility."
  print "Licenced under GNU GPLv3."
  print ""
  print "getbytes [start] [stop]"
  print "Displays memory bytes in range in a hexdecimal format."
  print ""
end
