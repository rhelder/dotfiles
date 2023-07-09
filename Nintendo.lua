meta = {
     __index = function(table, key)
          return 'Please try again.'
     end,
}

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

consoles = {}

for k, a in pairs(keywords) do
     for i, v in ipairs(a) do
	  consoles[v] = responses[k]
     end
end

setmetatable(consoles, meta)

print(consoles['NES'])
print(consoles['Wii'])
