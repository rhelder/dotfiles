" [TODO]
" * highlight messages
" * print to scratch buffer

function! shell#jobstart(cmd, opts = {}) abort
    call extend(a:opts, s:opts)
    if get(a:opts, 'msg', 0) && get(a:opts, 'scratch', 0)
        echohl ErrorMsg
        echomsg 'Invalid display opts: msg and scratch are mutually exclusive'
        echohl None
    endif

    call extend(a:opts, {'cmdheight': &cmdheight})

    let l:job_id = jobstart(a:cmd, a:opts)
    if !get(a:opts, 'sync', 1) | return l:job_id | endif

    call jobwait([l:job_id])

    let l:output = {
                \ 'stdout': a:opts.stdout,
                \ 'stderr': a:opts.stderr,
                \ 'both': a:opts.both,
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

    if get(self, 'msg', 0) && get(self, 'display_' .. a:event, 1) &&
                \ len(a:data) > 1
        if get(self, 'display_stdout', 1) &&
                    \ get(self, 'display_stderr', 1)
            let &cmdheight = len(self.both)
            echo join(self.both, "\n")
            redraw
        else
            let &cmdheight = len(self[a:event])
            echo join(self[a:event], "\n")
            redraw
        endif
    endif

    " Add last element of a:data to list; it may be concatenated with the first
    " element of a:data the next time the function is called
    if len(a:data) > 1
        call add(self[a:event], a:data[-1])
        call add(self.both, a:data[-1])
    endif
endfunction

function! s:on_exit(job_id, data, event) abort dict " {{{1
    call filter(self.stdout, '!empty(v:val)')
    call filter(self.stderr, '!empty(v:val)')
    call filter(self.both, '!empty(v:val)')

    if get(self, 'msg', 0)
        if get(self, 'display_stdout', 1) &&
                    \ get(self, 'display_stderr', 1)
            if !empty(self.both)
                if get(self, 'sync', 1)
                    echo self.both[-1] .. "\n"
                else
                    echo join(self.both, "\n") .. "\n\n"
                endif
            endif
        elseif !get(self, 'display_stdout', 1) &&
                    \ get(self, 'display_stderr', 1)
            if !empty(self.stderr)
                if get(self, 'sync', 1)
                    echo self.stderr[-1] .. "\n"
                else
                    echo join(self.stderr, "\n") .. "\n\n"
                endif
            endif
        elseif !get(self, 'display_stderr', 1) &&
                    \ get(self, 'display_stdout', 1)
            if !empty(self.stdout)
                if get(self, 'sync', 1)
                    echo self.stdout[-1] .. "\n"
                else
                    echo join(self.stdout, "\n") .. "\n\n"
                endif
            endif
        endif
    endif

    if !get(self, 'sync', 1)
        unlet self.stdout
        unlet self.stderr
        unlet self.both
        let &cmdheight = self.cmdheight
    endif
endfunction

" }}}1

let s:opts = {
            \ 'on_stdout': function('s:on_event'),
            \ 'on_stderr': function('s:on_event'),
            \ 'on_exit': function('s:on_exit'),
            \ }
