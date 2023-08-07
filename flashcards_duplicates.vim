function s:find_duplicates(pat) range
     let l:variant = 2
     if a:pat == 'quotes'
	  let s:search_pat = '^"\(.\{-}\)",'
	  function! s:subst_pat(variant)
	       return s:search_pat .. '/"\1(' .. a:variant .. ')",'
	  endfunction
     elseif a:pat == 'noquotes'
	  let s:search_pat = '^\([^\[].\{-}\),'
	  function! s:subst_pat(variant)
	       return s:search_pat .. '/\1(' .. a:variant .. '),'
	  endfunction
     endif
     let @0 = ''
     for i in range(a:firstline, a:lastline - 1)
	  silent! execute '/\%' .. i .. 'l' .. s:search_pat
	  execute 'normal ygn'
	  if @0 == ''
	  else
	       let l:word = @0
	       let @0 = ''
	       for j in range(i + 1, a:lastline)
		    silent! execute '/\%' .. j .. 'l' .. s:search_pat
		    execute 'normal ygn'
		    if @0 ==# l:word
			 execute j .. 'substitute/' .. s:subst_pat(l:variant)
			 let l:variant = l:variant + 1
		    endif
		    let @0 = ''
	       endfor
	       if l:variant > 2
		    let l:variant = 1
		    execute i .. 'substitute/' .. s:subst_pat(l:variant)
		    let l:variant = l:variant + 1
	       endif
	       unlet l:word
	  endif
     endfor
endfunction

%call s:find_duplicates('quotes')
%call s:find_duplicates('noquotes')
