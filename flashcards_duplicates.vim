let foo = '"wie viele",'
let variant = 1
let search_pattern1 = '^"\(.\{-}\)",'
let @0 = ''
for i in range(1, 61)
     silent! execute '/\%' .. i .. 'l' .. search_pattern1
     execute 'normal ygn'
     if @0 == foo
	  execute 'substitute/' .. search_pattern1 .. '/"\1(' .. variant .. ')",'
	  let variant = variant + 1
     endif
endfor

let foo = 'sie,'
let variant = 1
let search_pattern2 = '^\([^\[].\{-}\),'
for i in range(1, 61)
     silent! execute '/\%' .. i .. 'l' .. search_pattern2
     execute 'normal ygn'
     if @0 == foo
          execute 'substitute/' .. search_pattern2 .. '/\1(' .. variant .. '),'
          let variant = variant + 1
     endif
endfor
noh
