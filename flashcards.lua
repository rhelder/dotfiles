-- to-do
-- * Add just view flashcard option
-- * Add back-to-front review


-- title =

-- cards = {}


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


-- Define delay and iterator functions

function sleep(s)
     local ntime = os.clock() + s/10
     repeat until os.clock() > ntime
end


-- Start reviewing flashcards

print(title)
sleep(10)

review = {}
reverba = 0
for i, verbum in ipairs(rand) do
     print(verbum)
     if io.read() == cards[verbum] then
	  print('Correct')
     else print ('Incorrect. Correct answer: ' .. cards[verbum])
	  review[verbum] = cards[verbum]
	  reverba = reverba + 1
     end
     sleep(5)
end


-- Start loop for reviewing missed flashcards

print('Review missed cards')
sleep(10)

for i, verbum in ipairs(rand) do
     -- Create an array in which each key in table `review` is paired with a random number (clearing and re-using rand)
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
     for i, verbum in ipairs(rand) do
	  print(verbum)
	  if io.read() == cards[verbum] then
	       print('Correct')
	  else print ('Incorrect. Correct answer: ' .. cards[verbum])
	       review[verbum] = cards[verbum]
	       reverba = reverba + 1
	  end
	  sleep(5)
     end
end
