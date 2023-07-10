num_rows = 4
num_cols = 4

values = {
     'A', 'B', 'C', 'D',
     'E', 'F', 'G', 'H',
     'I', 'J', 'K', 'L',
     'M', 'N', 'O', 'P',
}
value = 1

matrix = {}
for i = 1,num_rows do
     matrix[i] = {}
     for j = 1,num_cols do
	  matrix[i][j] = values[value]
	  value = value + 1
     end
end

print(matrix[1][1])
print(matrix[2][4])
print(matrix[3][4])
print(values[12])

function coordinates(element)
     for i = 1,num_rows do
	  for j = 1,num_cols do
	       if matrix[i][j] == element then
		    return i, j
	       end
	  end
     end
end

row, col = coordinates('L')
print(row .. ', ' .. col)

---

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
