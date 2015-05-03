alert "Encryption Manager"
cls

mainmenu:
  $1 = "Encrypt,Decrypt,Exit"
  $2 = "Choose a process to perform"
  $3 = ""
  listbox $1 $2 $3 a
  if a = 3 then a = 0
  if a = 0 then cls
  if a = 0 then end
  
  $1 = ""
  askfile $1
  if $1 = "" then cls
  if $1 = "" then end
  
  x = ramstart
  load $1 x
  
  cls

  if s = 0 then print "File is blank!"
  if s = 0 then end
  
  print "Enter a encryption string> " ;
  input $2
  len $2 x
  if x = 0 then print "String is blank."

  if a = 2 then goto decrypt

encrypt:
  print "Encrypting file..."
  w = ramstart
  len $2 z
  y = 1

  for x = 1 to s
    peek v w
    string get $2 y t
    v = v + t
    poke v w
    w = w + 1
    y = y + 1
    if y > z then y = 1
  next x

  print "Complete!"
  delete $1
  if r > 0 then print "Could not replace file"
  if r > 0 then end
  x = ramstart
  save $1 x s
end

decrypt:
  print "Decrypting file..."
  w = ramstart
  len $2 z
  y = 1

  for x = 1 to s
    peek v w
    string get $2 y t
    v = v - t
    poke v w
    w = w + 1
    y = y + 1
    if y > z then y = 1
  next x
  
  print "Complete!"
  delete $1
  if r > 0 then print "Could not replace file"
  if r > 0 then end
  x = ramstart
  save $1 x s
end
