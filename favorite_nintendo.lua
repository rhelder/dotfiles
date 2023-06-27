print('One at a time, enter the names of three of the best Nintendo consoles.')
x = 3
while x > 0 do
     namepr = name
     name = io.read()
     if name == namepr then
	  print('Please try again.')
     elseif name == 'Nintendo Entertainment System' or name == 'NES' then
	  print('Classic choice!')
	  x = x -1
     elseif name == 'Super Nintendo Entertainment System' or name == 'SNES' or name == 'Super Nintendo' then
	  print('Super choice!')
	  x = x -1
     elseif name == 'Nintendo 64' or name == 'N64' then
	  print('Honestly, did it ever get better than this?')
	  x = x -1
     elseif name == 'Gamecube' or name == 'Nintendo Gamecube' then
	  print('Highly underrated, if you ask me.')
	  x = x -1
     elseif name == 'Nintendo Switch' or name == 'Switch' then
	  print('Hard to believe, but does it top them all?')
	  x = x -1
     else
	  print('Please try again.')
     end
end
