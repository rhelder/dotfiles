keywords = {
     nes = {'NES', 'Nintendo Entertainment System'},
     snes = {'SNES', 'Super Nintendo', 'Super Nintendo Entertainment System'},
     n64 = {'N64', 'Nintendo 64'},
     gc = {'GC', 'Gamecube', 'Nintendo Gamecube'},
     switch = {'Switch', 'Nintendo Switch'},
}

responses = {
     nes = 'Classic choice!',
     snes = 'Super choice!',
     n64 = 'Honestly, did it ever get better than this?',
     gc = 'Highly underrated, if you ask me.',
     switch = 'Hard to believe, but does it top them all?',
}

counts = {}
functions = {}

for k, v in pairs(keywords) do
     counts[k] = 0
     functions[k] = function(n)
	  if counts[k] == 0 then
	       counts[k] = 1
	       n = n + 1
	       return responses[k], n
	  end
	  responses[k] = 'Please try again.'
	  return responses[k], n
     end
end

consoles = {}

for k, a in pairs(keywords) do
     for i, v in ipairs(a) do
	  consoles[v] = functions[k]
     end
end

other = {
     __index = function(table, key)
	  return function(n) 
	       return 'Please try again.', n
	  end
     end
}

setmetatable(consoles, other)

print('One at a time, enter the names of three of the best Nintendo consoles.')
n = 1
repeat
     response, n = consoles[io.read()](n)
     print(response)
until n > 3
