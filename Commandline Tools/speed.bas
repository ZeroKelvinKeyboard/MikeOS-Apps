REM BASIC speed test (SPEED.BAS)
REM Create by Joshua Beck
REM Release under the GNU General Public Licence revision 3
REM Requires MikeOS 4.3b5 Minimum.

CURSPOS X Y

START:
  MOVE X Y
  PRINT "Working..." ;
  A = TIMER
  B = A + 182
  D = 0
  E = 0

TEST:
  D = D + 1
  IF D = 65535 THEN E = E + 1
  C = TIMER
  IF C > B THEN GOTO FINISHED
GOTO TEST

FINISHED:
  D = D / 10
  W = 0

  IF E = 1 AND D < 10001 THEN W = 1
  IF E = 1 AND D < 10001 THEN D = D * 6
  IF W = 1 THEN GOTO OUTPUT

  IF E = 1 AND D > 10000 THEN W = 1
  IF E = 1 AND D > 10000 THEN E = E * 6
  IF W = 1 THEN GOTO OUTPUT

  IF E > 1 THEN E = E * 6
  IF E > 1 THEN GOTO OUTPUT

OUTPUT:
  MOVE X Y
  PRINT "          "
  MOVE X Y
  PRINT E ;
  PRINT " X 65536 + " ;
  PRINT A ;
  PRINT " IPS"

ASKREDO:
  Y = Y + 1
  MOVE X Y
  PRINT "Test again (Y/N)";
  WAITKEY K
  IF K > 96 AND K < 123 THEN K = K - 32
  IF K = 'N' THEN GOTO ENDPROG
  IF K = 'Y' THEN GOTO REDO
GOTO ASKREDO

REDO:
  MOVE X Y
  PRINT "                "
  MOVE X Y
GOTO START

ENDPROG:
  MOVE X Y
  PRINT "                "
  MOVE X Y
END

