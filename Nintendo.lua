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

-- nes_response = 'Classic choice!'
-- trial = {
--      NES = nes_response
-- }
-- 
-- print(trial.NES)
-- trial['NES'] = 'Please try again.'
-- print(trial.NES)

--   tableoftables['NES']['nes'] = 'Classic choice!'
--   tableoftables['Nintendo Entertainment System']['nes'] = 'Classic choice!'
--   tableoftables['SNES']['snes'] = 'Super choice!'
--   tableoftables['Super Nintendo']['snes'] = 'Super choice!'
--   tableoftables['Super Nintendo']['snes'] = 'Super choice!'

table1 = {
     nes = 'Classic choice!',
     snes = 'Super choice!',
}

table2 = {
     nes = {'NES', 'Nintendo Entertainment System'},
     snes = {'SNES', 'Super Nintendo', 'Super Nintendo Entertainment System'},
}

tableoftables = {}
for k, a in pairs(table2) do
     tableoftables[k] = {}
     for i, v in ipairs(a) do 
	  tableoftables[k][v] = table1[k]
     end
end

-- print(tableoftables['nes']['NES'])
-- tableoftables['nes'] = 'Please try again.'
-- print(tableoftables['nes']['Nintendo Entertainment System'])
-- print(tableoftables['snes']['SNES'])
-- tableoftables['snes'] = 'Please try again.'
-- print(tableoftables['snes']['Super Nintendo'])
-- print(tableoftables['snes']['Super Nintendo Entertainment System'])

metatrial = {
     nes = {'NES', 'Nintendo Entertainment System'},
     nes_response = 'Classic choice!'
     for i, v in ipairs(nes) do
	  v = nes_response
     end
     snes = {'SNES', 'Super Nintendo', 'Super Nintendo Entertainment System'},
