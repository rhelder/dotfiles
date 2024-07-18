" [TODO]
" * highlight messages
" * print to scratch buffer

function! shell#jobstart(cmd, opts = {}) abort " {{{1
    call extend(a:opts, s:opts)
    call extend(a:opts, {'cmdheight': &cmdheight})
    if !has_key(a:opts, 'createqflist')
        call extend(a:opts, {'createqflist': function('s:createqflist')})
    endif

    let l:job_id = jobstart(a:cmd, a:opts)
    if !get(a:opts, 'sync', 1) | return l:job_id | endif

    call jobwait([l:job_id])

    let l:output = {
                \ 'stdout': filter(a:opts.stdout, '!empty(v:val)'),
                \ 'stderr': filter(a:opts.stderr, '!empty(v:val)'),
                \ 'both': filter(a:opts.both, '!empty(v:val)'),
                \ }

    unlet a:opts.stdout
    unlet a:opts.stderr
    unlet a:opts.both

    let &cmdheight = a:opts.cmdheight

    return l:output
endfunction

function! s:on_event(job_id, data, event) abort dict " {{{1
    " The first and last elements of a:data might not be complete lines.
    " Therefore, initialize lists with one empty element so that a:data[0] can
    " be concatenated with first element
    if !has_key(self, a:event) | let self[a:event] = [''] | endif
    if !has_key(self, 'both') | let self.both = [''] | endif

    let self[a:event][-1] ..= a:data[0]
    let self.both[-1] ..= a:data[0]

    " Any list element of a:data that's not first or last are complete lines,
    " newlines, or EOF, so just append them to the lists
    if len(a:data) > 2
        call extend(self[a:event], a:data[1:-2])
        call extend(self.both, a:data[1:-2])
    endif

    if get(self, 'msg', 0) && len(a:data) > 1
        call self.print_msg(a:event)
    endif

    " Add last element of a:data to list; it may be concatenated with the first
    " element of a:data the next time the function is called
    if len(a:data) > 1
        call add(self[a:event], a:data[-1])
        call add(self.both, a:data[-1])
    endif
endfunction

function! s:on_exit(job_id, data, event) abort dict " {{{1
    if get(self, 'msg', 0)
        call self.print_msg(a:event)
    endif

    if get(self, 'qf', 0)
        call call(self.createqflist, get(self, 'qf_args', [0, '']))
    endif

    if !get(self, 'sync', 1)
        unlet self.stdout
        unlet self.stderr
        unlet self.both
        let &cmdheight = self.cmdheight
    endif
endfunction

function! s:print_msg(event) abort dict " {{{1
    if a:event ==# 'exit'
        if &cmdheight !=# 1 | set cmdheight-=1 | endif
        if get(self, 'display_stdout', 1) &&
                    \ get(self, 'display_stderr', 1)
            let l:msg = self.both
        elseif !get(self, 'display_stdout', 1) &&
                    \ get(self, 'display_stderr', 1)
            let l:msg = self.stderr
        elseif !get(self, 'display_stderr', 1) &&
                    \ get(self, 'display_stdout', 1)
            let l:msg = self.stdout
        endif
        if l:msg ==# [''] | return | endif

        mode
        if get(self, 'sync', 1)
            echo join(l:msg, "\n")
        else
            echo join(l:msg, "\n") .. "\n"
        endif
        return
    endif

    if !get(self, 'display_' .. a:event, 1) | return | endif

    if get(self, 'display_stdout', 1) &&
                \ get(self, 'display_stderr', 1)
        let &cmdheight = len(self.both)
        echo join(self.both, "\n")
    else
        let &cmdheight = len(self[a:event])
        echo join(self[a:event], "\n")
    endif
    redraw
endfunction

function! s:createqflist(window, title = '', height = '') abort dict " {{{1
    silent cexpr self.both
    if a:window
        call setqflist(filter(getqflist(), 'v:val.valid !=# 0'))
        if !empty(a:title)
            call setqflist([], 'a', {'title': a:title})
        endif
        execute 'cwindow ' .. a:height
    endif
endfunction

" }}}1

let s:opts = {
            \ 'on_stdout': function('s:on_event'),
            \ 'on_stderr': function('s:on_event'),
            \ 'on_exit': function('s:on_exit'),
            \ 'print_msg': function('s:print_msg'),
            \ }
