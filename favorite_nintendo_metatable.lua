Console = {
     response = 'Please try again',
     keywords = {},
}

Console.new = function(self, object)
     object = object or {}
     setmetatable(object, self)
     self.__index = self
     return object
end

Console.PrintResponse = function(self)
     print(self.response)
end

Nes = Console:new()
Nes.response = 'Classic choice!'
-- Nes.keywords = {'NES', 'Nintendo Entertainment System'}
Nes['NES'] = Nes.response
Nes['Nintendo Entertainment System'] = Nes.response
Nes.__index = function(table, key)
     return Nes[key]
     -- for i, v in ipairs(Nes.keywords) do
     --      if key == v then
     --           print('success')
     --           return Nes.response
     --      end
     -- end
end
Snes = Console:new()
Snes.response = 'Super choice!'
N64 = Console:new()
N64.response = 'Honestly, did it ever get better than this?'
Gc = Console:new()
Gc.response = 'Highly underrated, if you ask me.'
Switch = Console:new()
Switch.response = 'Hard to believe, but does it top them all?'

-- NES = Nes:new()
-- "SNES" = Snes:new()
-- "Super Nintendo" = Snes:new()
-- "Super Nintendo Entertainment System" = Snes:new()
-- "N64" = N64:new()
-- "Nintendo 64" = N64:new()
-- "GC" = Gc:new()
-- "Gamecube" = Gc:new()
-- "Nintendo Gamecube" = Gc:new()
-- "Switch" = Switch:new()
-- "Nintendo Switch" = Switch:new()

console_names = {}
setmetatable(console_names, Nes)

print('Try entering the name of one of the best Nintendo consoles.')

print(console_names['NES'])
print(console_names['Wii'])

-- input = io.read()
-- name = load('return ' .. input)()
-- name:PrintResponse()
