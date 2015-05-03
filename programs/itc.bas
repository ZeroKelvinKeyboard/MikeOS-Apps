rem ITC - A Simple text compression program
rem Version 1.0.0
rem Copyright (C) Joshua Beck
rem Email: mikeosdeveloper@gmail.com
rem Licenced under the GNU General Public Licence v3

rem Requires Hack library
include "hacklib.bas"

v = 32768
gosub xmem
d = ramstart

parameters:
  if $1 = "" then goto help
  gosub collect_parameter

  if $2 = "COMPRESS" then goto compress
  if $2 = "DECOMPRESS" then goto decompress
  if $2 = "INFO" then goto information
  if $2 = "HELP" then goto help
goto help

collect_parameter:
  x = & $1
  x = x + w
  do
    x = x + 1
    peek v x
    if v = 0 then v = 32
  loop until v = 32
  poke 0 x
  x = & $1
  x = x + w
  string load $2 x
  case upper $2
  len $2 v
  w = w + v + 1
return

compress:
  print "Testing source file..."
  gosub collect_parameter
  size $2
  if r = 1 then goto file_not_found
  if s = 0 then goto blank_file
  
  print "Creating new ITC file..."
  d = ramstart
  $4 = "ITC"
  string store $4 d
  d = d + 4
  poke 1 d
  d = d + 1
  pokeint 24 d
  d = d + 4
  pokeint s d
  d = d + 2
  string store $2 d
  d = ramstart
  for x = 0 to 24
    peek v d
    d = d + 1
    gosub xput
  next x

  print "Opening source file..."
  rem >>> Percentage indicators <<<
  e = s / 4
  f = e * 2
  g = e * 3
  d = ramstart
  load $2 d

  print "Compressing source file...0%..." ;
  x = 24
  $4 = "**"
  do
    rem >>> Update string of last two characters <<<
    rem >>> Shift second one to first and collect a new one <<<
    z = & $4
    z = z + 1
    peek v z
    z = z - 1
    poke v z
    z = z + 1
    peek v d
    poke v z 
    d = d + 1

    if l = 1 then goto no_pattern_check

    rem >>> Pattern Matching <<<

    rem >>> Temporarily covert lowercase to capital for matching <<<
    z = & $4
    peek y z
    z = z + 1
    peek u z

    c = 0
    if y > 96 and y < 123 and u > 96 and u < 123 then c = 1
    if y > 96 and y < 123 and u > 96 and u < 123 then case upper $4

    rem >>> Check if the last two letters are one of our patterns <<<
    if $4 = "TH" then v = 128
    if $4 = "HE" then v = 129
    if $4 = "AN" then v = 130
    if $4 = "RE" then v = 131
    if $4 = "ER" then v = 132
    if $4 = "IN" then v = 133
    if $4 = "ON" then v = 134
    if $4 = "AT" then v = 135
    if $4 = "ND" then v = 136
    if $4 = "ST" then v = 137
    if $4 = "ES" then v = 138
    if $4 = "EN" then v = 139
    if $4 = "OF" then v = 140
    if $4 = "TE" then v = 141
    if $4 = "ED" then v = 142
    if $4 = "OR" then v = 143
    if $4 = "TI" then v = 144
    if $4 = "HI" then v = 145
    if $4 = "AS" then v = 146
    if $4 = "TO" then v = 147
    if $4 = "LL" then v = 148
    if $4 = "EE" then v = 149
    if $4 = "SS" then v = 150
    if $4 = "OO" then v = 151
    if $4 = "BE" then v = 152
    if $4 = "IS" then v = 153
    if $4 = "IT" then v = 154
    if $4 = "OF" then v = 155
    if $4 = "QU" then v = 156
    if $4 = "EX" then v = 157
    if $4 = "  " then v = 188
    if $4 = ", " then v = 189
    if $4 = "? " then v = 190
    if $4 = "! " then v = 191
    if $4 = ". " then v = 192
    if c = 1 and v > 127 then v = v + 30
    if c = 1 then case lower $4

    z = & $4
    peek y z
    z = z + 1
    peek u z
    if y > 64 and y < 91 and u = 32 and v < 128 then v = y + 128
    if y > 96 and y < 123 and u = 32 and v < 128 then v = y + 122

    no_pattern_check:
    
    if l = 1 then l = 0
    if v > 127 then x = x - 1
    gosub xput
    x = x + 1
    if v > 127 then l = 1
    s = s - 1

    if s = g then print "25%..." ;
    if s = f then print "50%..." ;
    if s = e then print "75%..." ;
  loop until s = 0  
  print "100%"

  y = x
  x = 7
  v = y % 256
  gosub xput
  x = x + 1
  v = y / 256
  gosub xput

  print "Copy data to output file..."
  d = ramstart
  for x = 0 to y
    gosub xget
    poke v d
    d = d + 1
  next x

  print "Saving output file..."
  d = ramstart
  gosub collect_parameter
  delete $2
  save $2 d y
  if r > 0 then goto save_failed
  print "Compression complete!"
end
  
decompress:
  print "Opening compressed file..."
  gosub collect_parameter
  d = ramstart
  load $2 d
  if r = 1 then goto file_not_found
  if s = 0 then goto blank_file

  print "Checking file is valid..."
  string load $2 d
  if $2 = "ITC" then d = d + 4
  else goto invalid_file
  peek v d
  if v > 1 then goto invalid_version
  d = d + 1
  peek o d
  d = d + 6
  string load $3 d

  s = s - o
  e = e / 4
  f = f * 2
  g = e * 3
  x = 0
  d = ramstart
  d = d + o

  print "Decompressing source file...0%..." ;
  $4 = ""
  do
    peek v d
    if v > 127 then gosub special
    gosub xput
    d = d + 1
    x = x + 1
    s = s - 1

    if s = g then print "25%..." ;
    if s = f then print "50%..." ;
    if s = e then print "75%..." ;
  loop until s = 0
  print "100%"
  
  print "Recreating original file..."
  d = ramstart
  y = x - 1
  for x = 0 to y
    gosub xget
    poke v d
    d = d + 1
  next x

  print "Saving output file..."
  d = ramstart
  delete $3
  save $3 d y

  print "Decompression complete."
  end
  
  special:
    c = 0
    if v > 157 and v < 188 then c = 1
    if v > 157 and v < 188 then v = v - 30

    if v = 128 then $4 = "TH"
    if v = 129 then $4 = "HE"
    if v = 130 then $4 = "AN"
    if v = 131 then $4 = "RE"
    if v = 132 then $4 = "ER"
    if v = 133 then $4 = "IN"
    if v = 134 then $4 = "ON"
    if v = 135 then $4 = "AT"
    if v = 136 then $4 = "ND"
    if v = 137 then $4 = "ST"
    if v = 138 then $4 = "ES"
    if v = 139 then $4 = "EN"
    if v = 140 then $4 = "OF"
    if v = 141 then $4 = "TE"
    if v = 142 then $4 = "ED"
    if v = 143 then $4 = "OR"
    if v = 144 then $4 = "TI"
    if v = 145 then $4 = "HI"
    if v = 146 then $4 = "AS"
    if v = 147 then $4 = "TO"
    if v = 148 then $4 = "LL"
    if v = 149 then $4 = "EE"
    if v = 150 then $4 = "SS"
    if v = 151 then $4 = "OO"
    if v = 152 then $4 = "BE"
    if v = 153 then $4 = "IS"
    if v = 154 then $4 = "IT"
    if v = 155 then $4 = "OF"
    if v = 156 then $4 = "QU"
    if v = 157 then $4 = "EX"
    if c = 1 then case lower $4

    if v = 188 then $4 = "  "
    if v = 189 then $4 = ", "
    if v = 190 then $4 = "? "
    if v = 191 then $4 = "! "
    if v = 192 then $4 = ". "

    z = & $4
    if v > 192 and v < 219 then y = v - 128
    if v > 218 and v < 245 then y = v - 122
    if v > 192 and v < 245 then poke y z
    z = z + 1
    if v > 192 and v < 245 then poke 32 z

    z = & $4
    peek v z
    gosub xput
    x = x + 1
    z = z + 1
    peek v z
  return

information:
  gosub collect_parameter
  load $2 d
  if r = 1 then goto file_not_found
  if s = 0 then goto blank_file

  string load $3 d
  if $3 = "ITC" then rem
  else goto invalid_file
  x = d + 4
  peek a x
  if a > 1 then goto invalid_version
  x = d + 7
  peekint b x
  x = d + 9
  peekint c x
  x = d + 11
  string load $7 x

  $3 = "Version:           " + A
  $4 = "Compressed Size:   " + B
  $5 = "Original Size:     " + C
  $6 = "Original Filename: " + $7

  print "ITC Information"
  print "==============="  
  print $3
  print $4
  print $5
  print $6
end

help:
  print "================================"
  print "ITC: Incredible Text Compression"
  print "================================"
  print "A simple plain text compression system"
  print "Copyright (C) Joshua Beck"
  print "Email: mikeosdeveloper@gmail.com"
  print "Licenced under the GNU General Public Licence v3"
  print ""
  print "Syntax: ITC (command) (INFILE) [OUTFILE]"
  print ""
  print "Commands:"
  print "    compress - Compress INFILE into ITC format and save to OUTFILE"
  print "    decompress - Decompress INFILE and save to old name"
  print "    info - Collect information about compressed file INFILE"
  print "    help - Display this help"
  print ""
end

file_not_found:
  print "FAILED: File not found."
  end

blank_file:
  print "FAILED: Blank file."
  end

save_failed:
  print "FAILED: Read-only disk or bad filename."
  end

invalid_file:
  print "FAILED: Not a valid ITC file."
  end

invalid_version:
  print "FAILED: File version not supported"
  end

 