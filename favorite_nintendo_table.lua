consoles = {}

nes = {'Nintendo Entertainment System', 'NES'}
snes = {'Super Nintendo Entertainment System', 'Super Nintendo', 'SNES'}
n64 = {'Nintendo 64', 'N64'}
gc = {'Nintendo Gamecube', 'Gamecube'}
switch = {'Nintendo Switch', 'Switch'}

keys = {nes, snes, n64, gc, switch}
values = {}

values[nes] = 'Classic choice!'
values[snes] = 'Super choice!'
values[n64] = 'Honestly, did it ever get better than this?'
values[gc] = 'Highly underrated, if you ask me.'
values[switch] = 'Hard to believe, but does it top them all?'

function iterate(array)
     local index = 0
     return function()
	  index = index + 1
	  return array[index]
     end
end

-- for key in iterate(keys) do
--      for name in iterate(key) do
-- 	  consoles[name] = values[key]
--      end
-- end
     
for key in iterate(keys) do
     consoles[key] = {}
     for name in iterate(key) do
	  consoles[key][name] = values[key]
     end
end

print(consoles[nes]['NES'])

function row(input)
     for key in iterate(keys) do
	  for name in iterate(key) do
	       if name == input then
		    return key
	       end
	  end
     end
end

var = row('NES')
print(var)

-- function key(console)
--      for key in iterate(consoles[key]) do
-- 	  for name in iterate(consoles[key][name]) do
-- 	       if console == name then
-- 		    return key
-- 	       end
-- 	  end
--      end
-- end

print('One at a time, please enter the names of three of the best Nintendo consoles.')
-- print(key(io.read()))


-- for response in concatenate(responses) do
--      consoles_responses[response] = {}
--      for console in concatenate(consoles) do
-- 	  consoles_responses[response] = console
--      end
-- end



-- consoles = {
--      NES = NES_response,
--      ['Nintendo Entertainment System'] = NES_response,
--      ['Super Nintendo Entertainment System'] = SNES_response,
--      SNES = SNES_response,
--      ['Super Nintendo'] = SNES_response,
--      ['Nintendo 64'] = N64_response,
--      N64 = N64_response,
--      Gamecube = GC_response,
--      ['Nintendo Gamecube'] = GC_response,
--      Switch = Switch_response,
--      ['Nintendo Switch'] = Switch_response,
-- }
-- 
-- function best(table)
--      return function()
-- 	  key = io.read()
-- 	  if table[key] == nil then
-- 	       return 'Please try again.'
-- 	  else
-- 	       return table[key]
-- 	       table[key] = nil
-- 	  end
--      end
-- end
-- 
-- print('Please name the five best Nintendo consoles.')
-- for console in best(consoles) do
--      print(console)
-- end
