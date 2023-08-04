" to-do
" *  Instead of just clearing yank register, yank some random text so that
"    current yank is saved in subsequent registers, then overwrite yank
"    register
" *  Correct variant numbers (right now, too low by one, because original
"    match is not being scanned)

let @0 = ''
let variant = 2
let search_pattern1 = '^"\(.\{-}\)",'
for i in range(1,60)
     silent! execute '/\%' .. i .. 'l' .. search_pattern1
     execute 'normal ygn'
     if @0 == ''
     else
	  let word = @0
	  let @0 = ''
	  " echo 'word is: ' .. word
	  " echo 'line is: ' .. i
	  for j in range(i + 1, 61)
	       " echo 'j is: ' .. j
	       silent! execute '/\%' .. j .. 'l' .. search_pattern1
	       execute 'normal ygn'
	       if @0 ==# word
	            " echo 'match is: ' .. word
	            " echo 'line is: ' .. j
	            execute j .. 'substitute/' .. search_pattern1 .. '/"\1(' .. variant .. ')",'
	            let variant = variant + 1
	       endif
	       let @0 = ''
	  endfor
	  if variant > 2
	       let variant = 1
	       execute i .. 'substitute/' .. search_pattern1 .. '/"\1(' .. variant .. ')",'
	       let variant = variant + 1
	  endif
	  unlet word
     endif
endfor

" let search_pattern2 = '^\([^\[].\{-}\),'
" for i in range (1,60)
"      let variant = 1
"      silent! execute '/\%' .. i .. 'l' .. search_pattern2
"      execute 'normal ygn'
"      let word = @0
"      for j in range(i + 1, 61)
" 	  silent! execute '/\%' .. j .. 'l' .. search_pattern2
" 	  execute 'normal ygn'
" 	  if @0 ==# word
" 	       execute 'substitute/' .. search_pattern2 .. '/\1(' .. variant .. '),'
" 	       let variant = variant + 1
" 	  endif
"      endfor
" endfor

noh
