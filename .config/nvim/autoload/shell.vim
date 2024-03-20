function! shell#jobstart(cmd, opts = {}) abort
    let l:opts = {
            \ 'on_stdout': function('s:on_event'),
            \ 'on_stderr': function('s:on_event'),
            \ 'on_exit': function('s:on_exit'),
            \ }
    call extend(a:opts, l:opts)

    let l:job_id = jobstart(a:cmd, a:opts)
    if has_key(a:opts, 'sync') | call jobwait([l:job_id]) | endif

    if has_key(a:opts, 'stdout') | unlet a:opts.stdout | endif
    if has_key(a:opts, 'stderr') | unlet a:opts.stderr | endif
    if has_key(a:opts, 'both') | unlet a:opts.both | endif
    if has_key(a:opts, 'stderr_indices') | unlet a:opts.stderr_indices | endif

    return l:job_id
endfunction

function! s:on_event(job_id, data, event) abort dict " {{{1
    if a:event ==# 'stdout'
        let l:other = 'stderr'
    elseif a:event ==# 'stderr'
        let l:other = 'stdout'
        if !has_key(self, 'stderr_indices')
            let self.stderr_indices = []
        endif
    endif

    " Initialize lists with one empty element so that a:data[0] can be
    " concatenated with it
    if !has_key(self, a:event) | let self[a:event] = [''] | endif
    if !has_key(self, 'both') | let self.both = [''] | endif

    " The index at which we're starting for this event
    let l:event_start = len(self[a:event]) - 1
    " The index at which we're starting for both events
    let l:output_start = len(self.both) - 1

    " Both the first element and the last element of a:data can be an
    " incomplete line. Therefore, concatenate the first element of a:data with
    " the last element of self[a:event] (which is either the last element of
    " a:data from the last time s:on_event was called, or the empty first
    " element of self[a:event]
    let self[a:event][-1] ..= a:data[0]
    " The rest of the elements of a:data represent complete lines, so they can
    " just be added to self[a:event]
    call extend(self[a:event], a:data[1:-2])
    " Do the same with self.both
    let self.both[-1] ..= a:data[0]
    call extend(self.both, a:data[1:-2])

    " Keep track of indices at which the output is coming from stderr
    if a:event ==# 'stderr'
        let l:output_end = len(self.stdout) -1 + len(self.stderr) - 1
        call extend(self.stderr_indices, range(l:output_start, l:output_end))
    endif

    if has_key(self, 'scratch') " {{{2
        if !l:output_start
            let l:pos = getcurpos()
            let l:winnr = bufwinnr('%')

            " If a scratch buffer is not currently open, open a new scratch
            " buffer. Otherwise, re-use the current scratch buffer
            let self.scratch.winnr = bufwinnr(get(self.scratch, 'bufnr', -1))
            if self.scratch.winnr == -1
                execute get(self.scratch, 'height', 10) .. 'new'
                let self.scratch.winnr = bufwinnr('%')
                let self.scratch.bufnr = bufnr('%')
                let self.scratch.winid = bufwinid('%')
                setlocal buftype=nofile
                setlocal nocursorline
                setlocal bufhidden=wipe
                setlocal nonumber
                setlocal scrolloff=0
            else
                execute self.scratch.winnr 'wincmd w'
                silent %delete _
            endif

            execute l:winnr 'wincmd w'
            call setpos('.', l:pos)

            call setbufline(self.scratch.bufnr, 1, self[a:event][0])
            let self[a:event][0] = ''
        endif

        for line in self[a:event][l:event_start:]
            " Elements indicating a newline or EOF will be empty, so don't
            " print those
            if empty(line) | continue | endif
            let l:lnum = line('$', self.scratch.winid)
            call appendbufline(self.scratch.bufnr, l:lnum, line)
            " Scroll down as text is appended
            call win_execute(self.scratch.winid, 'normal! G')
        endfor
    endif
    " }}}2

    " Tack on the last element of a:data, which may be an incomplete line. If
    " it is, it will be completed when the function is called next (see
    " comments above). If it isn't, it will be an empty element indicating
    " either a newline or EOF, so it's harmless to add it to the list
    call add(self[a:event], a:data[-1])
    call add(self.both, a:data[-1])
endfunction

function! s:on_exit(job_id, data, event) abort dict " {{{1
    if has_key(self, 'scratch') && has_key(self, 'stderr_indices')
        for index in self.stderr_indices
            let l:lnum = index + 1
            if a:data
                call win_execute(self.scratch.winid,
                            \ 'call matchaddpos("ErrorMsg", [l:lnum])')
            else
                call win_execute(self.scratch.winid,
                            \ 'call matchaddpos("WarningMsg", [l:lnum])')
            endif
        endfor
    endif

    if has_key(self, 'sync')
        for event in self.sync.events
            if !has_key(self, event) | continue | endif

            let i = 0
            for line in self[event]
                if empty(line) | continue | endif

                if event ==# 'stderr'
                    if a:data
                        echohl ErrorMsg
                    else
                        echohl WarningMsg
                    endif
                    execute get(self.sync, event, 'echomsg') .. string(line)
                    echohl None

                elseif event ==# 'both' && has_key(self, 'stderr_indices')
                    if i == self.stderr_indices[0]
                        call remove(self.stderr_indices, 0)
                        if a:data
                            echohl ErrorMsg
                        else
                            echohl WarningMsg
                        endif
                        execute get(self.sync, 'stderr', 'echomsg') ..
                                    \ string(line)
                        echohl None
                    else
                        execute get(self.sync, 'stdout', 'echo') ..
                                    \ string(line)
                    endif
                    let i += 1

                elseif event ==# 'stdout'
                    execute get(self.sync, event, 'echo') .. string(line)
                endif
            endfor
        endfor
    endif
endfunction

" }}}1
