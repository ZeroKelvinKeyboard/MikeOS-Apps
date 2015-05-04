goto start
command:
                                                                                                                                                              

DO NOT MODIFY TOP LINES!
The length is important for our Self-Modifing Code

------> Information <------
MikeBASIC Interactive Interpreter (BASIC.BAS)
Made by Joshua Beck
Released under GNU GPLv3
Version 1.2.3
Send any feature requests, bug reports or changes to:
mikeosdeveloper@gmail.com 
Requires MikeOS 4.3 or better.

START:
  REM ------> Startup <------

  REM blank stored variables
  FOR X = 65498 TO 65514
    POKE 0 X
  NEXT X

  REM are there parameters?
  IF $1 = "" THEN GOTO NOPARA

  REM if so use commandline mode
  POKE 1 65498
  $8 = $1
  CURSPOS X Y
  POKE X 65500
  POKE Y 65501
GOTO PROMPT

NOPARA:
  REM if there were no parameters start in interactive mode
  POKE 0 65498
  CLS
  MOVE 0 2
  GOSUB INTRO
  POKE 0 65500
  POKE 7 65501
GOTO PROMPT

INTRO:
  REM ------> About Command <------

  REM executed on startup
  PRINT "MikeBASIC Interactive Interpreter"
  PRINT "Developed by Joshua Beck"
  PRINT "Released under GNU GPLv3"
  PRINT "Type HELP for how to use and EXIT to quit"
  PRINT ""
  U = 1
RETURN

EMPTYCMD:
  REM ------> String blanking <------

 
  FOR Y = 1 TO 2
    IF Y = 1 THEN W = P
    IF Y = 2 THEN W = & $8
    FOR X = 1 TO 128
      POKE 32 W
      W = W + 1
    NEXT X
  NEXT Y
RETURN

PROMPT:
  REM ------> Main command loader <------

  REM see if we are running in commandline mode, if so only do one command
  PEEK V 65498
  IF V = 2 THEN END
  IF V = 1 THEN V = 2
  POKE V 65498

  REM locate the command space
  P = PROGSTART
  P = P + 20

  REM if we are in interactive mode prompt for a command
  IF V = 0 THEN GOSUB ASKCMD
  IF $8 = "" THEN GOTO PROMPT
  GOSUB SPCMD
  IF U = 1 THEN GOTO PROMPT

  REM copy from string into command location
  Y = & $8
  W = P
  X = 0
  COPYLINE:
    PEEK Z Y
    IF Z = 10 THEN GOTO ENDCMD
    IF Z = 0 THEN GOTO ENDCMD
    IF Z = 58 THEN Z = 10
    POKE Z W
    X = X + 1
    Y = Y + 1
    W = W + 1
  IF X < 128 THEN GOTO COPYLINE
  ENDCMD:
  POKE 10 W
  W = W + 1
  FOR X = 1 TO 6
    READ RETWORD X Z
    POKE Z W
    W = W + 1
  NEXT X
  POKE 10 W

  GOSUB GETVAR
  GOSUB COMMAND
  GOSUB PUTVAR
GOTO PROMPT

ASKCMD:
  REM ------> Command Bar <------

  REM clear current command
  GOSUB EMPTYCMD

  REM save ink colour
  Y = INK
  POKE Y 65499

  REM erase previous text off the screen
  INK 31
  MOVE 0 0
  FOR X = 0 TO 159
    PRINT " ";
  NEXT X

  REM prompt for input in the top line
  MOVE 0 0
  PRINT "MikeBASIC> " ;
  INPUT $8

  REM restore ink colour
  INK Y
RETURN
  
RETWORD:
82 69 84 85 82 78

GETVAR:
  REM ------> Load saved variables <------

  REM get the cursor position
  PEEK X 65500
  PEEK Y 65501
  MOVE X Y
  REM load the variables for the program
  PEEKINT U 65502
  PEEKINT V 65504
  PEEKINT W 65506
  PEEKINT X 65508
  PEEKINT Y 65510
  PEEKINT Z 65512
  PEEKINT P 65514
RETURN

PUTVAR:
  REM ------> Save current variables <------

  REM save the variable the interpreter uses
  POKEINT U 65502
  POKEINT V 65504
  POKEINT W 65506
  POKEINT X 65508
  POKEINT Y 65510
  POKEINT Z 65512
  POKEINT P 65514

  REM save cursor position
  CURSPOS X Y
  REM make sure it's not on the top lines  
  IF Y < 2 THEN Y = 2
  POKE X 65500
  POKE Y 65501
RETURN

SPCMD:
  REM ------> Check special commands <------

  U = 0
  REM get cursor position
  PEEK X 65500
  PEEK Y 65501
  MOVE X Y
  REM special commands
  IF $8 = "END" THEN $8 = "EXIT"
  IF $8 = "End" THEN $8 = "EXIT"
  IF $8 = "end" THEN $8 = "EXIT"
  IF $8 = "Exit" THEN $8 = "EXIT"
  IF $8 = "exit" THEN $8 = "EXIT"
  IF $8 = "End" THEN $8 = "EXIT"
  IF $8 = "EXIT" THEN CLS
  IF $8 = "EXIT" THEN END
  IF $8 = "help" THEN $8 = "HELP"
  IF $8 = "Help" THEN $8 = "HELP"
  IF $8 = "HELP" THEN GOSUB HELP
  IF $8 = "about" THEN $8 = "ABOUT"
  IF $8 = "About" THEN $8 = "ABOUT"
  IF $8 = "ABOUT" THEN GOSUB INTRO
  IF $8 = "fillrnd" THEN $8 = "FILLRND"
  IF $8 = "FILLRND" THEN GOSUB FILLRND
  IF $8 = "invert" THEN $8 = "INVERT"
  IF $8 = "Invert" THEN $8 = "INVERT"
  IF $8 = "INVERT" THEN GOSUB INVERT
  REM save cursor position
  CURSPOS X Y
  POKE X 65500
  POKE Y 65501
RETURN

HELP:
  REM ------> Help command <------

  PRINT "MikeBASIC Interactive Interpreter"
  PRINT "Information on commands can be found at:"
  PRINT "mikeos.berlios.de/handbook-appdev-basic.html"
  PRINT "You can us ':' to seperate multiple commands"
  PRINT "FOR X = 1 TO 5 : PRINT X : NEXT X"
  IF V = 0 THEN PRINT "This is interactive mode."
  IF V = 1 THEN PRINT "This is commandline mode."
  IF V = 0 THEN PRINT "You can also run at command line"
  IF V = 0 THEN PRINT "> BASIC PRINT $1"
  IF V = 1 THEN PRINT "You can also run in interactive mode:"
  IF V = 1 THEN PRINT "> BASIC"
  PRINT "Special commands are: EXIT, HELP, ABOUT, FILLRND, INVERT"
  U = 1
RETURN

FILLRND:
  REM ------> Fillrnd Command <------

  MOVE 0 0
  FOR Y = 0 TO 24
    FOR X = 0 TO 79
      RAND W 16 255
      INK W
      RAND W 1 254
      PRINT CHR W ;
    NEXT X
  NEXT Y
  MOVE 0 2
  PEEK X 65499
  INK X
  U = 1
RETURN

INVERT:
  REM ------> Invert command <------

  REM swap background and foreground colour
  MOVE 0 0
  FOR Y = 0 TO 24
    FOR X = 0 TO 79
      CURSCOL W
      Z = W % 16
      Z = Z * 16
      W = W / 16
      W = W + Z
      INK W
      CURSCHAR W
      PRINT CHR W ;
    NEXT X
  NEXT Y
  PEEK X 65499
  INK X
  U = 1
RETURN

