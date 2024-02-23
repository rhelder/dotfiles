nnoremap <buffer> <Leader>fh <Cmd>call <SID>toggle_help_filetype()<CR>
nnoremap <buffer> <Leader>rr <Cmd>call <SID>right_align_right_column('tag')<CR>
vnoremap <buffer> <Leader>rt :call <SID>right_align_right_column('tag')<CR>
vnoremap <buffer> <Leader>rl :call <SID>right_align_right_column('link')<CR>
nnoremap <buffer> <Leader>== <Cmd>execute "normal! o\<lt>Esc>78i=\<lt>Esc>"<CR>
nnoremap <buffer> <Leader>=- <Cmd>execute "normal! o\<lt>Esc>78i-\<lt>Esc>"<CR>

function! s:toggle_help_filetype() abort " {{{1
    if &filetype ==# 'text'
        setlocal filetype=help
    elseif &filetype ==# 'help'
        setlocal filetype=text
    endif
endfunction

function! s:right_align_right_column(type) abort range " {{{1
    if a:type == 'tag'
        let l:pattern = '\v\*.*\*'
    elseif a:type == 'link'
        let l:pattern = '\v\|.*\|'
    endif

    let l:lengths = []
    for line in range(a:firstline, a:lastline)
        call add(l:lengths, len(matchstr(getline(line), l:pattern)))
    endfor
    let l:line_with_max = index(l:lengths, max(l:lengths)) + a:firstline

    call cursor(l:line_with_max,
                \ match(getline(l:line_with_max), l:pattern) + 1)
    execute "normal " .. (78 - virtcol('$') + 1) .. "i \<Esc>"
    let l:col_of_max = match(getline(l:line_with_max), l:pattern)
    for line in range(a:firstline, a:lastline)
        if line == l:line_with_max || !len(matchstr(getline(line), l:pattern))
            continue
        endif

        let l:col = match(getline(line), l:pattern)
        call cursor(line, l:col + 1)
        execute 'normal ' .. (l:col_of_max - l:col) .. "i \<Esc>"
    endfor
endfunction

" }}}1
