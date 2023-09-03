-- to-do
-- * Consider reading `csv` file directly


-- Define delay function

function sleep(s)
     local ntime = os.clock() + s/10
     repeat until os.clock() > ntime
end


-- Initialize and ask for modes

print(title)
sleep(5)

print('Review front or back of flashcards (f/b)?')
while true do
     local mode = io.read()
     if mode == 'f' then
	  if cards_front ~= nil then
	       cards = cards_front
	  end
	  break
     elseif mode == 'b' then
	  if cards_back ~= nil then
	       cards = cards_back
	  end
	  break
     else
	  print("Please type either 'f' or 'b'.")
     end
end

print('Type or view answers (t/v)?')
while true do
     mode = io.read()
     if mode == 't' then
	  break
     elseif mode == 'v' then
	  break
     else
	  print("Please type either 't' or 'v'.")
     end
end

sleep(5)


-- Loop to automatically find number of cards

verba = 0

for k, v in pairs(cards) do
     verba = verba + 1
end


-- Create an array in which each key in `cards` is paired with a random number

rand = {}
math.randomseed(os.time())

for k, v in pairs(cards) do
     local num = math.random(verba)
     -- Make sure there are no duplicates
     while rand[num] ~= nil do
	  num = math.random(verba)
     end
     rand[num] = k
end


-- Start reviewing flashcards

review = {}
reverba = 0

for i, verbum in ipairs(rand) do
     print(verbum)
     if mode == 't' then
	  if io.read() == cards[verbum] then
	       print('Correct')
	  else print ('Incorrect. Correct answer: ' .. cards[verbum])
	       review[verbum] = cards[verbum]
	       reverba = reverba + 1
	  end
     end
     if mode == 'v' then
	  io.read()
	  print(cards[verbum])
	  sleep(5)
	  print('Learned? (y/n)')
	  while true do
	       local learned = io.read()
	       if learned == 'y' then
		    break
	       elseif learned == 'n' then
		    review[verbum] = cards[verbum]
		    reverba = reverba + 1
		    break
	       else
		    print("Please type either 'y' or 'n'.")
	       end
	  end
     end
     sleep(5)
end


-- Review missed flashcards

for i, verbum in ipairs(rand) do

     -- Create an array in which each key in `review` is paired with a unique random number (clearing and re-using `rand`)
     rand = {}

     for k, v in pairs(review) do
	  local num = math.random(reverba)
	  while rand[num] ~= nil do
	       num = math.random(reverba)
	  end
	  rand[num] = k
     end

     -- Start reviewing missed flashcards (clearing and re-using `review` and `reverba`)
     review = {}
     reverba = 0

     print('Review missed flashcards')
     sleep(10)

     for i, verbum in ipairs(rand) do
	  print(verbum)
	  if mode == 't' then
	       if io.read() == cards[verbum] then
		    print('Correct')
	       else print ('Incorrect. Correct answer: ' .. cards[verbum])
		    review[verbum] = cards[verbum]
		    reverba = reverba + 1
	       end
	  end
	  if mode == 'v' then
	       io.read()
	       print(cards[verbum])
	       sleep(5)
	       print('Learned? (y/n)')
	       while true do
		    local learned = io.read()
		    if learned == 'y' then
			 break
		    elseif learned == 'n' then
			 review[verbum] = cards[verbum]
			 reverba = reverba + 1
			 break
		    else
			 print("Please type either 'y' or 'n'.")
		    end
	       end
	  end
	  sleep(5)
     end

     if reverba == 0 then
	  break
     end

end