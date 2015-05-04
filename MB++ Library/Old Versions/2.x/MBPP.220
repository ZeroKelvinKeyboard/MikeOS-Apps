REM >>>>MIKEBASIC-PLUS-PLUS-LIBRARY<<<
MOVE 0 0
PRINT "Fatal application ran into framework!"
END
STARTPRG:
  CLS
  CURSOR OFF
  FOR X = 65000 TO 65535
    POKE 0 X
  NEXT X
  GOSUB DEFCOL
  A = 0
  IF $z = "NOINT" THEN GOTO NOINT
  IF $z = "BASEINT" THEN GOTO BASEINT
  IF $z = "FULLINT" THEN GOTO FULLINT
  IF $z = "" THEN GOTO NOINT
  $e = "Invalid Runmode!"
  IF A = 0 THEN GOSUB ERRBOX
  IF A = 0 THEN GOSUB ENDPROG
  FULLINT:
    GOSUB ANISTART
    Z = 7
    GOSUB SETTITLE
    GOSUB CONTENT
  BASEINT:
    Z = 7
    GOSUB BORDER
    C = 7
    H = 14
    T = 7
  NOINT:
    C = 0
    H = 0
    J = 0
    V = 0
    W = 0
    X = 0
    Y = 0
    Z = 0
    $b = ""
    $c = ""
    $e = ""
    $f = ""
    $g = ""
    $t = ""
    $z = ""
RETURN
boxsave:
  j = 64610
  poke 7 65525
  for y = 8 to 17
    for x = 20 to 59
      move x y
      curschar w
      poke w j
      poke 32 65520
      call 65515
      j = j + 1
    next x
  next y
  return
boxrest:
  j = 64610
  poke 7 65525
  for y = 8 to 17
    for x = 20 to 59
      move x y
      peek w j
      poke w 65520
      call 65515
      j = j + 1
    next x
  next y
  return
aniclose:
  if $y = "DISABLE" then return
  j = 176
  gosub blockbox
  pause 1
  j = 177
  gosub blockbox
  pause 1
  j = 178
  gosub blockbox
  pause 1
  j = 219
  gosub blockbox
  pause 1
  return
aniopen:
  if $y = "DISABLE" then return
  j = 219
  gosub blockbox
  pause 1
  j = 178
  gosub blockbox
  pause 1
  j = 177 
  gosub blockbox
  pause 1
  j = 176
  gosub blockbox
  pause 1
  return
anistart:
  if $y = "DISABLE" then return
  j = 176
  gosub blockscr
  pause 1
  j = 177
  gosub blockscr
  pause 1
  j = 178
  gosub blockscr
  pause 1
  j = 219
  gosub blockscr
  pause 1
  j = 178
  gosub blockscr
  j = 219
  gosub blockbor
  pause 2
  j = 177
  gosub blockscr
  j = 219
  gosub blockbor
  pause 2
  j = 176
  gosub blockscr
  j = 219
  gosub blockbor
  pause 2
  j = 0
  gosub blockscr
  move 2 1
  print $t
  j = 219
  gosub blockbor
  pause 2
  j = 178
  gosub blockbor
  pause 1
  j = 177
  gosub blockbor
  pause 1
  j = 176
  gosub blockbor
  return
aniend:
  if $y = "DISABLE" then return
  j = 176
  gosub blockscr
  pause 1
  j = 177
  gosub blockscr
  pause 1
  j = 178
  gosub blockscr
  pause 1
  j = 219
  gosub blockscr
  pause 5
  j = 178
  gosub blockscr
  pause 1
  j = 177
  gosub blockscr
  pause 1
  j = 176
  gosub blockscr
  pause 1
  j = 0
  gosub blockscr
  pause 1
  return
ancitext:
  poke c 65525
  poke x 65431
ancitex2:
  if x > w then y = y + 1
  if x > w then peek x 65431
  if x > 78 then y = y + 1
  if x > 78 then peek x 65431
  if y > 23 then return
  move x y
  peek j v
  if j = 0 then return
  if j = 1 then v = v + 1
  if j = 1 then goto ancitex2
  if j = 7 then j = 255
  if j = 10 then y = y + 1
  if j = 10 then peek x 65431
  if j = 10 then v = v + 1
  if j = 10 then goto ancitex2
  poke j 65520
  call 65515
  x = x + 1
  v = v + 1
  goto ancitex2  
pictotxt:
  for x = 0 to 19
    for y = 0 to 76
      peek w v
      if w = 0 then w = 32
      poke w v
      v = v + 1
    next y
    poke 10 v
    v = v + 1
    poke 1 v
    v = v + 1
    poke 1 v
    v = v + 1
  next x
  return
askbox:
  gosub boxsave
  move 22 9
  print $t
  gosub aniopen
  gosub box
  move 22 9
  print $t
  move 22 11
  print $b
  move 22 12
  print $c
  move 22 13
  print $e
  move 22 14
  print $f
  move 22 15
  print $g
  move 27 16
  print "--Yes--        --No--"
  poke 0 65423
  gosub askdraw
  askloop:
    waitkey j
    if j = 3 then gosub swleft
    if j = 4 then gosub swright
    if j = 13 then goto askend
  goto askloop
askend:
  gosub aniclose
  gosub boxrest
  peek v 65423
  j = v
  if j = 0 then v = 1
  if j = 1 then v = 0
  return
swleft:
  peek v 65423
  if v = 0 then return
  gosub askblank
  peek v 65423
  if v = 1 then v = 0
  poke v 65423
  gosub askdraw
  return
swright:
  peek v 65423
  if v = 1 then return
  gosub askblank
  peek v 65423
  if v = 0 then v = 1
  poke v 65423
  gosub askdraw
  return
askblank:
  w = h
  h = 0
  y = 16
  for x = 27 to 33
    gosub highlight
  next x
  for x = 42 to 47
    gosub highlight
  next x    
  h = w
  return
askdraw:
  peek v 65423
  if v = 0 then x = 26
  if v = 1 then x = 41
  y = 16
  if v = 0 then for w = 1 to 7
  if v = 1 then for w = 1 to 6
    x = x + 1
    gosub highlight
  next w
  return
mesbox:
  gosub boxsave
  move 22 9
  print $t
  gosub aniopen
  cursor off
  gosub box
  move 22 9
  print $t 
  move 22 11
  print $b
  move 22 12
  print $c
  move 22 13
  print $e
  move 22 14 
  print $f
  move 22 15
  print $g
  move 22 16
  print "Press any key to continue..."
  waitkey k
  gosub aniclose
  gosub boxrest
  return
inpbox:
  gosub boxsave
  move 22 9
  print $t
  gosub aniopen
  cursor off
  gosub box   
  move 22 9 
  print $t
  move 22 12
  print $b
  move 22 13
  print $c
  move 22 14
  print ">"
  move 23 14
  cursor on
  a = 0
  $i = ""
  if v = 0 then input a
  if v = 1 then input $i
  cursor off
  gosub aniclose
  gosub boxrest
  return
errbox:
  gosub boxsave
  move 22 9
  print "Error"
  gosub aniopen
  gosub box
  move 22 9
  print "Error"
  move 22 12
  print $e
  move 22 14
  print "Press any key to continue."
  cursor on
  move 48 14
  waitkey k
  if k = 27 then gosub endprog
  cursor off
  gosub aniclose
  gosub boxrest
  return
clear:
  goto refresh
dinbox:
  gosub boxsave
  move 22 9
  print $t
  gosub aniopen
  gosub box
  move 22 9
  print $t
  move 22 11
  print $b
  move 22 12
  print ">"
  move 23 12
  cursor on
  if v = 0 then input b
  if v = 1 then input $b
  cursor off
  move 22 13
  print $c
  move 22 14
  print ">"
  move 23 14
  cursor on
  if v = 0 then input d
  if v = 1 then input $c
  cursor off
  gosub aniclose
  gosub boxrest
  return
numbox:
  gosub boxsave
  move 22 9
  print $t
  gosub aniopen
  gosub box
  move 22 9
  print $t
  if $b = "" then goto numboxa
  move 22 11
  print $b
  move 22 12
  print a
  numboxa:
  if $c = "" then goto numboxb
  move 22 13
  print $c
  move 22 14
  print b
  numboxb:
  move 22 16
  print "Press any key to continue..."
  waitkey j
  gosub aniclose
  gosub boxrest
  return
refresh:
  cls
  gosub border
  gosub title
  gosub content
  return
defcol:
  poke 156 65515
  poke 80 65516
  poke 83 65517
  poke 81 65518
  poke 184 65519
  poke 32 65520
  poke 9 65521
  poke 183 65522
  poke 0 65523
  poke 179 65524
  poke 7 65525
  poke 185 65526
  poke 1 65527
  poke 0 65528
  poke 205 65529
  poke 16 65530
  poke 89 65531
  poke 91 65532
  poke 88 65533
  poke 157 65534
  poke 195 65535
  return
endprog:
  z = 7
  gosub aniend
  cls
  cursor on
  end
blockbor:
  poke z 65525
  poke j 65520
  for x = 0 to 79
    move x 0
    call 65515
    move x 2
    call 65515
    move x 24
    call 65515
  next x
  for x = 1 to 23
    move 0 x
    call 65515
    move 79 x
    call 65515
  next x
  return
border:
  peek j 65525
  poke z 65525
  poke 218 65520
  move 0 0
  call 65515
  poke 196 65520
  for x = 1 to 78
    move x 0
    call 65515
  next x
  move 79 0
  poke 191 65520
  call 65515
  move 0 1
  poke 179 65520
  call 65515
  move 79 1
  call 65515
  move 0 2
  poke 195 65520
  call 65515
  move 79 2
  poke 180 65520
  call 65515
  poke 196 65520
  for x = 1 to 78
    move x 2
    call 65515
  next x
  poke 179 65520 
  for x = 3 to 23
    move 0 x
    call 65515
    move 79 x
    call 65515
  next x
  move 0 24
  poke 192 65520
  call 65515
  move 79 24
  poke 217 65520
  call 65515
  poke 196 65520  
  for x = 1 to 78
    move x 24
    call 65515
  next x
  poke j 65525
  return
blockscr:
  poke z 65525
  poke j 65520
  for x = 0 to 79
    for j = 0 to 24
      move x j
      call 65515
    next j
  next x
  peek j 65520
  return
settitle:
  poke z 65525
  poke z 65439 
  move 2 1
  print $t
  j = 65439
  for x = 2 to 76
    j = j + 1
    move x 1
    curschar w
    poke w j
    poke w 65520
    call 65515
  next x
  return
title:
  peek j 65439
  poke j 65525
  j = 65439
  for x = 2 to 76
    j = j + 1
    peek w j
    poke w 65520
    move x 1
    print chr w
    move x 1
    call 65515
  next x
  return
blockbox:
  poke t 65525
  poke j 65520
  x = 8
  for x = 8 to 17
    move 20 x
    call 65515
  next x
  for x = 21 to 58
    move x 8
    call 65515
    move x 10
    call 65515
    move x 17
    call 65515
  next x
  for x = 8 to 17
    move 59 x
    call 65515
  next x
return
box:
  peek j 65525
  poke t 65525
  move 20 8
  poke 218 65520
  call 65515
  move 59 8
  poke 191 65520
  call 65515
  poke 196 65520
  for x = 21 to 58
    move x 8
    call 65515
  next x
  move 20 9
  poke 179 65520
  call 65515
  move 59 9
  call 65515
  move 20 10
  poke 195 65520
  call 65515
  move 59 10
  poke 180 65520
  call 65515
  poke 179 65520
  for x = 11 to 16
    move 20 x
    call 65515
    move 59 x
    call 65515
  next x
  move 20 17
  poke 192 65520
  call 65515
  move 59 17
  poke 217 65520
  call 65515
  poke 196 65520
  for x = 21 to 58
    move x 10
    call 65515
  next x
  poke 196 65520
  for x = 21 to 58
    move x 17
    call 65515
  next x
  move 21 9
  print "                                      "
  for x = 11 to 16
    move 21 x
    print "                                      "
  next x
  poke 7 65525
  for x = 21 to 58
    move x 9
    curschar w
    poke w 65520
    call 65515
  next x
  for y = 11 to 16
    for x = 21 to 58
      move x y
      curschar w
      poke w 65520
      call 65515
    next x
  next y
  poke j 65525
  return
highlight:
  j = h
  j = j * 16
  j = j + c
  poke j 65525
  move x y
  curschar j
  move x y 
  poke j 65520
  call 65515
  return
colour:
  poke c 65525
  move x y 
  curschar j
  move x y
  poke j 65520
  call 65515
  return
arrayget:
  if $v = "a" then j = 0
  if $v = "b" then j = 100
  if $v = "c" then j = 200
  if $v = "d" then j = 300
  j = j + 60000
  if $v = "a" then w = a
  if $v = "b" then w = b
  if $v = "c" then w = c
  if $v = "d" then w = d
  if w > 99 then $e = "Array over maximum"
  if w < 0 then $e = "Number below zero"
  if w > 99 then goto errbox
  if w < 0 then goto errbox
  j = j + w
  peek v j
  return
arrayput:
  if $v = "a" then j = 0
  if $v = "b" then j = 100
  if $v = "c" then j = 200
  if $v = "d" then j = 300
  j = j + 60000
  if $v = "a" then w = a
  if $v = "b" then w = b
  if $v = "c" then w = c
  if $v = "d" then w = d
  if w > 99 then $e = "Array over maximum"
  if w < 0 then $e = "Number below zero"
  if w > 99 then goto errbox
  if w < 0 then goto errbox
  j = j + w
  poke v j
  return
xput:
  $e = "XPUT: invalid location!"
  if e < 0 then goto errbox
  if e > 8096 then goto errbox
  j = 32767 - e
  poke v j
  return
xget:
  $e = "XGET: invalid location!"
  if e < 0 then goto errbox
  if e > 8096 then goto errbox
  j = 32767 - e
  peek v j
  return
loadbox:
  poke v 65434
  u = 11453
  findend:
    u = u + 1
    peek v u
    if v > 0 then goto findend
  u = u - 2
  poke 0 65435
  poke 1 65436
  peek w 65437
  poke 0 65438
  gosub boxsave
  move 22 9
  print $t
  gosub aniopen
  gosub box
  move 22 9
  print $t
  menufunc:
    poke 0 65424
    if v < 6 then gosub menua
    if v = 6 then gosub loadback
    if v = 6 then poke 0 65438
rem    if v = 6 then gosub lbhelper
    if v = 6 then goto menufunc
    if v = 7 then gosub loadforw
    if v = 7 then poke 4 65438
rem    if v = 7 then gosub lbhelper
    if v = 7 then goto menufunc
  poke 0 65436
  x = s
  y = r
  peek v 65434
  load $i v
  $e = "File not found! Has disk changed?"
  j = r
  v = s
  r = y
  s = x
  if j = 1 then gosub errbox
  gosub aniclose
  gosub boxrest
  return 
lbhelper:
  poke 1 65424
  poke w 65438
  if w > 4 then gosub loadint
  if w > 4 then gosub menuloop
  return
menubox:
  gosub boxsave
  move 22 9
  print $t
  gosub aniopen
  gosub box
  move 22 9
  print $t
  poke 0 65436
  poke 0 65438
  menufun2:
    gosub menua
    if v < 6 then goto menufun3
    if v = 6 then poke 0 65438
    if v = 7 then poke 4 65438
  goto menufun2
  menufun3:
  poke v 65432
  gosub aniclose
  gosub boxrest  
  peek v 65432
  return
menua:
  peek j 65436
  if j = 1 then goto loadint
  move 22 11
  print $b
  move 22 12
  print $c
  move 22 13
  print $e
  move 22 14
  print $f
  move 22 15
  print $g
  loadret:
  move 22 16
  print "Press enter to select."
  poke c 65525
  peek w 65438
  w = w + 11
  y = 9
  for x = 22 to 58
    gosub colour
  next x
  for y = 11 to 16
    for x = 22 to 58
      gosub colour
      if w = y then gosub highlight
    next x
  next y
  w = w - 11
  menuloop:
    waitkey j
    x = 0
    v = 0
    if j = 1 then gosub menublan
    if j = 1 then w = w - 1
    if w < 0 then x = 1
    if x = 1 then w = 5 
    if x = 1 then goto refafter
    if j = 1 then poke w 65438
    if j = 1 then gosub menuchan
    if j = 1 then goto menuloop
    if j = 2 then gosub menublan
    if j = 2 then w = w + 1
    if w > 4 then x = 2
    if x = 2 then w = 6
    if x = 2 then goto refafter
    if j = 2 then poke w 65438
    if j = 2 then gosub menuchan
    if j = 2 then goto menuloop
    if j = 13 then goto refaftr2
    if j = 27 then gosub endprog
  goto menuloop
  refaftr3:
    peek w 65438
    w = w + 11
    move 23 w
    $i = "            "
    x = & $i
    y = 23
    getfilen:
      move y w
      curschar j
      if j < 33 then poke 0 x
      if j < 33 then return
      poke j x
      x = x + 1
      y = y + 1
      goto getfilen
  refaftr2:
    peek w 65436
    if w = 1 then gosub refaftr3
    peek w 65438
    v = w + 1
    return
  refafter:
    poke w 65438
    for y = 11 to 16
      move 21 y
      for x = 21 to 58
        print " ";
      next x
    next y
    peek w 65438
    if w = 4 then gosub menuchan
    if w = 6 then gosub menuchan
    v = w + 1
    return
  menublan:
    poke c 65525
    for y = 11 to 16
      for x = 22 to 58
        move x y
        curschar v
        poke v 65520
        call 65515
      next x
    next y
    return
  menuchan:
    poke w 65433
    peek w 65436
    if w = 1 then goto chanload
    peek w 65433
    if w = 6 then w = 4
    if w = 5 then w = 0
    poke w 65433
    chanload:
    peek w 65433
    w = w + 11
    v = h * 16
    v = v + c
    poke v 65525
    for y = 11 to 16
      for x = 22 to 58
        if w = y then move x y
        if w = y then curschar v
        if w = y then poke v 65520
        if w = y then call 65515
      next x
    next y
    w = w - 11
    peek w 65438
    return
loadint:
  move 22 9
  print "Select a file to load..."
  w = 0
  peek j 65435
  j = j + 11454
  x = 23
  y = 11
  move x y
  fncon:
    move x y
    peek i j
    if i = 0 then goto lintret
    print chr i
    if j > u then goto loadover
    if j > u then gosub loadback
    if j > u then goto lintret
    if i = ',' then w = w + 1
    if i = ',' then move x y
    if i = ',' then print " "
    if i = ',' then x = 22
    if i = ',' then y = y + 1
    if w = 5 then goto lintret  
    x = x + 1
    j = j + 1
  goto fncon
  lintret:
    peek j 65424
    if j = 0 then goto loadret
    if j = 1 then return
  return
loadover:
  gosub loadback
  poke u 65435
  goto loadret
loadforw:
  x = 0 
  j = 0
  peek j 65435
  j = j + 11454
  lmfc:
    peek x j
    j = j + 1
    if x = 44 then j = j - 11454
    if x = 44 then poke j 65435
    if x = 44 then return
  goto lmfc
loadback:
  x = 0
  j = 0
  y = 0
  peek j 65435
  j = j + 11454
  lmbc:
    peek x j
    j = j - 1
    if x = 0 then j = 11008
    if x = 0 then poke j 65435
    if x = 0 then return
    if j < 0 then y = 3
    if y = 3 then j = 0
    if y = 3 then poke 0 65435
    if y = 3 then return
    if x = ',' then y = y + 1
    if y = 2 then j = j - 11454
    if y = 2 then j = j + 2
    if y = 2 then poke j 65435
    if y = 2 then return
  goto lmbc
