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

function! notes#exit_note() abort " {{{1
    if !filereadable(expand('%')) | return | endif

    if string(v:exiting) ==# 'v:null'
        if !getbufvar(expand('<afile>'), 'modified', 0) | return | endif

        call mdview#compiler#convert(1, {
                    \ 'scratch_win': {
                    \   'title': ['[Warning] mdView', '[Error] mdView'],
                    \ },
                    \ 'bufnr': bufnr(expand('<afile>')),
                    \ 'callback': function('s:mdview_callback'),
                    \ })

    else
        if getbufvar(expand('<afile>'), 'modified', 0)
            call mdview#compiler#convert(0, {'sync': 1})
        endif

        if get(s:, 'modified', 0)
            call shell#compile(['build-index'], {'sync': 1})
            let s:modified = 0
        endif
    endif
endfunction

function! s:mdview_callback(job, status, event) abort dict " {{{2
    if a:event !=# 'exit' | return | endif

    call setbufvar(bufname(self.bufnr), 'modified', 0)

    if !s:modified | return | endif

    call shell#compile(['build-index'], {
                \ 'mdview': self,
                \ 'on_error': function('s:build_index_on_error'),
                \ 'info': 'build-index',
                \ 'callback': function('s:build_index_callback'),
                \ })
endfunction

function! s:build_index_on_error(job, status, event) abort dict " {{{2
    if empty(self.stderr()) | return | endif

    call extend(self.output, self.mdview.output, 0)

    let self.scratch = 5

    let l:title = ['[Warning] build-index', '[Error] build-index']
    let s:scratch_win = shell#get_scratch_win()
    if empty(s:scratch_win)
        let self.scratch_win = self.mdview.scratch_win
        let self.scratch_win.title = l:title
    else
        let l:title = [
                    \ bufname(s:scratch_win.bufnr) .. ' ' .. l:title[0],
                    \ bufname(s:scratch_win.bufnr) .. ' ' .. l:title[1],
                    \ ]
        call shell#set_scratch_win({'title': l:title})
    endif

    let l:matches = getmatches(s:scratch_win.bufwinid)

    call self.load_scratch_buf(a:job, a:status, a:event)

    if empty(l:matches) | return | endif

    let l:match = l:matches[-1]
    let l:match.pos = []
    for [l:key, l:val] in items(l:match)
        if l:key =~# '\vpos\d+'
            call extend(l:match.pos, l:val)
        endif
    endfor

    call matchaddpos(
                \ l:match.group,
                \ l:match.pos,
                \ l:match.priority + 1,
                \ -1,
                \ {'window': s:scratch_win.bufwinid},
                \ )
endfunction

function! s:build_index_callback(job, status, event) abort dict " {{{2
    let s:modified = 0
endfunction
" }}}2

function! notes#set_modified(...) " {{{1
    let s:modified = a:0

    let l:file = expand('<afile>')
    if empty(l:file)
        let l:file = expand('%')
    endif

    if exists('a:1')
        setbufvar(l:file, 'modified', a:1)
    endif
endfunction

function! notes#mdview_output_file() abort dict " {{{1
    " If the input file is an index file, manipulate the filename so that the
    " html filename is exactly equivalent to the corresponding keyword, so that
    " it can be linked to in a Pandoc template
    let l:input = self.input()
    let l:head = fnamemodify(l:input, ':h')
    let l:tail = fnamemodify(l:input, ':t')
    let l:tail = substitute(l:tail, '^_', '@', '')
    let l:tail = substitute(l:tail, '_', ' ', 'g')
    let l:tail = substitute(l:tail, '.md$', '.html', '')
    let l:output = l:head .. '/' .. l:tail
    return l:output
endfunction

" }}}1
