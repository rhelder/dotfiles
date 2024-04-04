function! fzf#opts_expect(dict) abort " {{{1
    let l:options = []

    for key in keys(a:dict)
        let l:option = '--expect=' .. key
        call add(l:options, l:option)
    endfor

    return l:options
endfunction

function! fzf#open_files(lines, dict, func = '') abort " {{{1
    if len(a:lines) < 2
        return
    endif

    let l:key = a:lines[0]
    let l:results = a:lines[1:]
    if !empty(a:func)
        let l:results = call(a:func, [l:results])
    endif

    if type(get(a:dict, l:key, 'edit')) == v:t_func
        call a:dict[l:key](l:results)
    else
        execute get(a:dict, l:key, 'edit') l:results[0]
        call remove(l:results, 0)
        for result in l:results
            execute get(a:dict, l:key, '$argadd') result
        endfor
    endif
endfunction

function! fzf#toggle_vim_global_display_opts(bang) abort " {{{1
    if a:bang == 0
        augroup rfv
            autocmd!
            autocmd FileType fzf call s:vim_global_display_opts.get('popup')
            autocmd FileType fzf set noshowmode
            " Clear previous command
            autocmd FileType fzf echo ''
            autocmd FileType fzf autocmd BufLeave <buffer>
                        \ call s:vim_global_display_opts.restore()
            autocmd FileType fzf autocmd BufEnter <buffer> set noshowmode
        augroup END

    elseif a:bang == 1
        augroup rfv
            autocmd!
            autocmd FileType fzf call s:vim_global_display_opts.get('fullscreen')
            autocmd FileType fzf set laststatus=0 noshowmode showtabline=0
            " Clear previous command
            autocmd FileType fzf echo ''
            autocmd FileType fzf autocmd BufLeave <buffer>
                        \ call s:vim_global_display_opts.restore()
        augroup END
    endif
endfunction

" }}}1

let s:vim_global_display_opts = {
            \ 'fullscreen': ['&laststatus', '&showmode', '&showtabline'],
            \ 'popup': ['&showmode'],
            \ }

function! s:vim_global_display_opts.get(list_name) abort dict " {{{1
    let self.defaults = {}
    for key in self[a:list_name]
        let l:value = eval(key)
        let self.defaults[key] = l:value
    endfor
endfunction

function! s:vim_global_display_opts.restore() abort dict " {{{1
    for [key, value] in items(self.defaults)
        execute 'let ' .. key .. ' = ' .. value
    endfor
endfunction

" }}}1
