-- to-do
-- -- Add just view flashcard option
-- -- Add procedure for disambiguating duplicates. Rough idea:
-- -- -- Looping through each line, search that line for search pattern.
-- -- -- Using gn text object, yank search result and set it equal to variable
-- -- -- -- Looping through all of the other lines, yank the results of the search patterns for each of those lines also
-- -- -- -- Each time, compare the yanked text (in register "0) to the variable.
-- -- -- -- If they are, substitute with the same text plus a number
-- -- -- -- Increment the number
-- -- -- Reset number, reset variable, repeat


-- title =

-- vocab = {}


-- Loop to automatically find number of vocabulary words

verba = 0
for k, v in pairs(vocab) do
     verba = verba + 1
end


-- Create an array in which each vocabulary word (i.e., each key in table 'vocab') is paired with a random number

rand = {}

math.randomseed(os.time())
for k, v in pairs(vocab) do
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
sleep(5)

review = {}
reverba = 0
for i, verbum in ipairs(rand) do
     print(verbum)
     if io.read() == vocab[verbum] then
	  print('Correct')
     else print ('Incorrect. Correct answer: ' .. vocab[verbum])
	  review[verbum] = vocab[verbum]
	  reverba = reverba + 1
     end
     sleep(5)
end


-- Start loop for reviewing missed flashcards

for i, verbum in ipairs(rand) do

     -- Create an array in which each key in table 'review' is paired with a random number (clearing and re-using rand)
     rand = {}
     for k, v in pairs(review) do
	  local num = math.random(reverba)
	  while rand[num] ~= nil do
	       num = math.random(reverba)
	  end
	  rand[num] = k
     end

     -- Start reviewing missed flashcards (clearing and re-using review and reverba)
     review = {}
     reverba = 0
     for i, verbum in ipairs(rand) do
	  print(verbum)
	  if io.read() == vocab[verbum] then
	       print('Correct')
	  else print ('Incorrect. Correct answer: ' .. vocab[verbum])
	       review[verbum] = vocab[verbum]
	       reverba = reverba + 1
	  end
	  sleep(5)
     end
end
