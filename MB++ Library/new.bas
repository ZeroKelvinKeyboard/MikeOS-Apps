REM >>>MIKEOS BASIC PLUS PLUS LIBRARY<<<
REM Version 4.0.0
REM Copyright (C) Joshua Beck

PRINT "MB++ Library version 4.0.0"
END

REM A = X MARGIN
REM B = Y LIMIT
REM C = COLOUR
REM D = TEXTPTR
ANCITEXT:
  GOSUB PUSHVAR
  GOSUB PUSHLOC
  CURSPOS X Y
  F = INK
  W = D
  E = X
  
  DO
    PEEK V W
    IF V = 10 THEN GOSUB MBPPNL
    IF X > A THEN GOSUB MBPPNL
    IF V > 31 THEN PRINT CHR X;
  WHILE V = 0
  
MBPPNL:
  Y = Y + 1
  X = E
RETURN
  
