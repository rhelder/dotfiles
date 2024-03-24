function! shell#jobstart(cmd, opts = {}) abort
    let l:opts = {
            \ 'on_stdout': function('s:on_event'),
            \ 'on_stderr': function('s:on_event'),
            \ 'on_exit': function('s:on_exit'),
            \ }
    call extend(a:opts, l:opts)

    let l:job_id = jobstart(a:cmd, a:opts)
    if has_key(a:opts, 'sync') | call jobwait([l:job_id]) | endif

    if has_key(a:opts, 'sync')
        return get(a:opts.sync, 'is_output', 0)
    endif
endfunction

function! s:on_event(job_id, data, event) abort dict " {{{1
    " The first and last elements of a:data might not be complete lines.
    " Therefore, initialize lists with one empty element so that a:data[0] can
    " be concatenated with first element
    if !has_key(self, a:event) | let self[a:event] = [''] | endif
    if !has_key(self, 'both') | let self.both = [''] | endif

    " The index at which we're starting for this event
    let l:event_start = len(self[a:event]) - 1
    " The index at which we're starting for both events
    let l:output_start = len(self.both) - 1

    let self[a:event][-1] ..= a:data[0]
    let self.both[-1] ..= a:data[0]

    " Any list element of a:data that's not first or last are complete lines,
    " newlines, or EOF, so just append them to the lists
    if len(a:data) > 1
        call extend(self[a:event], a:data[1:-2])
        call extend(self.both, a:data[1:-2])
    endif

    " Keep track of indices at which the output is coming from stderr
    if a:event ==# 'stderr'
        if !has_key(self, 'stderr_indices')
            let self.stderr_indices = []
        endif
        let l:output_end = len(self.both) - 1
        call extend(self.stderr_indices, range(l:output_start, l:output_end))
    endif

    if has_key(self, 'scratch') " {{{2
        if !l:output_start && self[a:event] != ['']
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
            " Set the first element of the list to an empty string. This way,
            " the indices of the list aren't changed, and the first element
            " won't be printed again, since later we make sure empty elements
            " aren't printed
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

    " Add last element of a:data to list; it may be concatenated with the first
    " element of a:data the next time the function is called
    if len(a:data) > 1
        call add(self[a:event], a:data[-1])
        call add(self.both, a:data[-1])
    endif
endfunction

function! s:on_exit(job_id, data, event) abort dict " {{{1
    " Highlight stderr lines in scratch buffer
    if has_key(self, 'scratch') &&
                \ self.stderr != [''] &&
                \ has_key(self, 'stderr_indices')
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
        if has_key(self.sync, 'is_output') | unlet self.sync.is_output | endif
        for event in self.sync.events
            if self[event] == ['']
                continue
            else
                let self.sync.is_output = 1
            endif

            let l:i = 0
            for line in self[event]
                " Elements indicating a newline or EOF will be empty, so don't
                " echo those
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
                    " Highlight stderr lines
                    if l:i == self.stderr_indices[0]
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
                    let l:i += 1

                elseif event ==# 'stdout'
                    execute get(self.sync, event, 'echo') .. string(line)
                endif
            endfor
        endfor
    endif

    unlet self.stdout
    unlet self.stderr
    unlet self.both
    unlet self.stderr_indices
endfunction

" }}}1
