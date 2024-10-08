" [FIXME] When scratch buffer closes (e.g. because there are no mdview errors),
" the next time there's an error, it's likely that the next scratch buffer to
" be opened will be a different buffer, because it will have a different title.
" This can lead to 'buffer name already exists' errors

function! notes#exit#compile() abort " {{{1
    if !filereadable(expand('%')) | return | endif

    if string(v:exiting) ==# 'v:null'
        if !getbufvar(expand('<afile>'), 'modified', 0) | return | endif

        let l:title = ['[Warning] mdView', '[Error] mdView']
        if !empty(shell#get_scratch_win())
            call shell#set_scratch_win({'title': l:title})
        endif

        call mdview#compiler#convert(1, {
                    \ 'scratch_win': {
                    \   'title': l:title,
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

        let l:matches = getmatches(s:scratch_win.bufwinid)
    endif

    call self.load_scratch_buf(a:job, a:status, a:event)

    if !exists('l:matches') | return | endif

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

function! notes#exit#set_modified(...) " {{{1
    let s:modified = a:0

    let l:file = expand('<afile>')
    if empty(l:file)
        let l:file = expand('%')
    endif

    if exists('a:1')
        call setbufvar(l:file, 'modified', a:1)
    endif
endfunction

" }}}1
