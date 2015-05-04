rem Convert raw AAP to formatted AAP

m = ramstart
n = m + 4000

load $1 n
if r = 1 then print "File not found."
if r = 1 then end

print "Creating Metadata..." ;

rem //// Insert Meta-Information \\\\

rem #1 Identifier - 'AAP', 0
$4 = "AAP"
string store $4 m

rem #2 Version - 1
w = m + 4
poke 1 w

rem #3 Type - Picture
w = m + 5
poke 1 w

rem #4 Data Offset - 261 bytes
w = m + 6
pokeint 261 w

rem #5 Size, columns - 76 columns
w = m + 8
poke 76 w

rem #6 Size, rows - 20 rows
w = m + 9
poke 20 w

rem #7 Palette
w = m + 10

rem create a red palette with no background and each key as it's original
for x = 32 to 126
  poke 4 w
  w = w + 1
  poke x w
  w = w + 1
next x

rem now copy the source files' number palette across
s = n + 1991
d = m + 10 + 32

for x = 0 to 9
  poke 4 d
  d = d + 1
  peek v s
  s = s + 1
  poke v d
  d = d + 1
next x

rem #8 Title
print ""
print "Enter a title for the picture> " ;
input $4

x = & $4
x = x + 60
poke 0 x

w = m + 200
string store $4 w

rem //// Transfer Data \\\\

print "Converting image..." ;

s = n
d = m + 261

rem copy source to destination matrix and add color information

for y = 1 to 20
  for x = 1 to 76
    poke 4 d
    d = d + 1
    peek v s
    s = s + 1
    poke v d
    d = d + 1
  next x
  s = s + 4
next y

print ""
print "File conversion complete."

rem //// Save Output \\\\
do  
  print "Enter a name for the resulting file> " ;
  input $4
  delete $4
  save $4 m 3301
loop until r = 0

end 
