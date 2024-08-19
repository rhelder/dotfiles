function! notes#new_note() abort " {{{1
    lcd ~/Documents/Notes
    let l:name = strftime("%Y%m%d%H%M%S")
    execute 'edit ' .. l:name .. '.md'
    execute "normal i---\r---\<Esc>"
    execute "normal Okeywords: \<Esc>"
    execute "normal Otitle: \<Esc>"
    execute 'normal Oid: ' .. l:name .. "\<Esc>"
endfunction

function! notes#new_journal() abort " {{{1
    lcd $HOME/Documents/Notes
    execute 'edit ' .. strftime('%F') .. '.txt'
    if !filereadable(strftime('%F') .. '.txt')
        execute 'normal i' .. strftime('%A, %B %e, %Y') .. "\<Esc>"
        execute "normal 2o\<Esc>"
    endif
endfunction

function! notes#make_bracketed_list_hyphenated() abort " {{{1
    let l:unnamed_register = @"
    normal! ""di[
    let l:string = substitute(@", '\n', ' ', 'g')
    let l:list = split(l:string, ', ')
    call setline('.', substitute(getline('.'), '\(.*:\).*', '\1', ''))
    execute "normal o\<C-I>- " .. l:list[0] .. "\<Esc>"
    for item in l:list[1:-1]
        execute "normal! o- " .. item .. "\<Esc>"
    endfor
    let @" = l:unnamed_register
endfunction

" }}}1
