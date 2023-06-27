console_names = {}

console_names[1] = {'Nintendo Entertainment System', 'NES'}
console_names[2] = {'Super Nintendo Entertainment System', 'Super Nintendo', 'SNES'}
console_names[3] = {'Nintendo 64', 'N64'}
console_names[4] = {'Nintendo Gamecube', 'Gamecube'}
console_names[5] = {'Nintendo Switch', 'Switch'}

console_responses = {}

console_responses[1] = 'Classic choice!'
console_responses[2] = 'Super choice!'
console_responses[3] = 'Honestly, did it ever get better than this?'
console_responses[4] = 'Highly underrated, if you ask me.'
console_responses[5] = 'Hard to believe, but does it top them all?'

function iterate(array)
     local index = 0
     return function()
	  index = index + 1
	  return array[index]
     end
end

function row(element)
     for i = 1, #console_names do
	  for j in iterate(console_names[i]) do
	       if j == element then
		    return i
	       end
	  end
     end
end

function response(name)
     print('Please name one of the best Nintendo systems.')
     name = io.read()
     print(console_responses[row(name)])
end

response(name)
