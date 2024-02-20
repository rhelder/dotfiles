if exists('g:loaded_mdnotes')
    finish
endif
let g:loaded_mdnotes = 1

nnoremap <Leader>nj <Cmd>call <SID>new_journal()<CR>
nnoremap <Leader>nn <Cmd>call <SID>new_note()<CR>
nnoremap <Leader>ns <Cmd>call <SID>search_notes()<CR>
nnoremap <Leader>ni <Cmd>call fzf#run(fzf#wrap(<SID>browse_index()))<CR>

function! s:new_note() abort " {{{1
    lcd ~/Documents/Notes
    let l:name = strftime("%Y%m%d%H%M%S")
    execute 'edit ' .. l:name .. '.md'
    execute "normal i---\r---\<Esc>"
    execute "normal Okeywords: \<Esc>"
    execute "normal Otitle: \<Esc>"
    execute 'normal Oid: ' .. l:name .. "\<Esc>"
endfunction

function! s:new_journal() abort " {{{1
    lcd $HOME/Documents/Notes
    execute 'edit ' .. strftime('%F') .. '.txt'
    if !filereadable(strftime('%F') .. '.txt')
        execute 'normal i' .. strftime('%A, %B %e, %Y') .. "\<Esc>"
        execute "normal 2o\<Esc>"
    endif
endfunction

function! s:search_notes() abort " {{{1
    lcd $HOME/Documents/Notes
    Rfv [[:digit:]]*.md
endfunction

function! s:browse_index() abort " {{{1
    let l:browse_index_spec = {
                \ 'dir': "$HOME/Documents/Notes",
                \ 'source': 'fd "[A-z].*\.md"',
                \ 'left': '50',
                \ 'options': s:fzf_expect(),
                \ 'sinklist': function('s:browse_index_open_result'),
                \ }

    return l:browse_index_spec
endfunction

function! s:fzf_expect() abort " {{{2
    let l:options = []

    for key in keys(s:browse_index_action)
        let l:option = '--expect=' .. key
        call add(l:options, l:option)
    endfor

    return l:options
endfunction

let s:browse_index_action = {
            \ 'ctrl-v': 'vertical split',
            \ 'ctrl-x': 'split',
            \ 'ctrl-o': 'silent !md-open',
            \ }

function! s:browse_index_open_result(lines) abort " {{{2
    if len(a:lines) < 2
        return
    endif

    let l:key = a:lines[0]
    let l:result = a:lines[1]

    if type(get(s:browse_index_action, l:key, 'edit')) == v:t_func
        call s:browse_index_action[l:key](l:result)
    else
        execute get(s:browse_index_action, l:key, 'edit') l:result
    endif
endfunction
" }}}2

" }}}1
