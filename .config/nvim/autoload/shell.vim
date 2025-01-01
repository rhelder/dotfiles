function! shell#jobstart(cmd, opts = {}) abort " {{{1
    let l:job_handler = deepcopy(s:job_handler)
    call extend(l:job_handler, a:opts)
    let l:job_handler.cmd = a:cmd
    return l:job_handler.start()
endfunction

function! shell#job_handler(opts = {}) abort " {{{1
    return extend(deepcopy(s:job_handler), a:opts)
endfunction

" }}}1

function! s:on_output(job, data, event) abort dict " {{{1
    if !has_key(self, 'output')
        let self.output = [{'line': '', 'event': ''}]
    endif

    " If 'a:data' is EOF, we're done
    if a:data ==# [''] | return | endif

    " The first and last elements of 'a:data' might not be complete lines. The
    " first element of 'a:data' might be a continuation of the last element of
    " 'a:data' from the last time the function was called. If not, the last
    " element of 'a:data' from the last time the function was called was a "''"
    " (i.e., a newline). Either way, concatenate the first element of 'a:data'
    " with the last.
    let self.output[-1].line ..= a:data[0]
    let self.output[-1].event = a:event

    " Any elements of a:data that are not first or last are complete lines or
    " newlines.
    if len(a:data) > 2
        for l:line in a:data[1:-2]
            call add(self.output, {'line': l:line, 'event': a:event})
        endfor
    endif

    " If 'a:data' has only one element, it either is a continuation of the
    " 'a:data' passed to the function when it was last called, or will be
    " continued by the 'a:data' passed to the function when it is next called,
    " or both. But if there are two elements, the first element completes a
    " line, and the second element starts a new line. Therefore, don't print
    " any messages unless 'a:data' has at least two elements, or else we will
    " print incomplete lines.

    if get(self, 'scratch', 0) && len(a:data) > 1
        call self.load_scratch_buf(a:job, a:data, a:event)
    endif

    if get(self, 'msg', 0) && len(a:data) > 1
        call self.echo_output(a:job, a:data, a:event)
    endif

    " Unless 'a:data' is EOF the next time the function is called, the last
    " element of 'a:data' will be concatenated with the first element of
    " 'a:data' the next time the function is called, and the event will be
    " determined then.
    if len(a:data) > 1
        call add(self.output, {'line': a:data[-1], 'event': ''})
    endif

    if has_key(self, 'callback')
        call call(self.callback, [a:job, a:data, a:event])
    endif
endfunction

" }}}1

let s:job_handler = {
            \ 'on_stdout': function('s:on_output'),
            \ 'on_stderr': function('s:on_output'),
            \ }

function! s:job_handler.on_exit(job, status, event) abort dict " {{{1
    if get(self, 'scratch', 0)
        call self.load_scratch_buf(a:job, a:status, a:event)
    endif

    if get(self, 'msg', 0)
        call self.echo_output(a:job, a:status, a:event)
    endif

    if !empty(get(self, 'info', ''))
        call self.echo_info(a:job, a:status, a:event)
    endif

    if has_key(self, 'callback')
        call call(self.callback, [a:job, a:status, a:event])
    endif
endfunction

function! s:job_handler.load_scratch_buf(id, data, event) abort dict " {{{1
    if !exists('self.scratch_buf') | let self.scratch_buf = {} | endif

    if a:event ==# 'exit'
        let l:scratch = copy(self.scratch)
        if l:scratch ># 3 | let l:scratch -= 3 | endif

        if l:scratch ==# 3
            let l:output = self.both()
        elseif l:scratch ==# 2
            let l:output = self.stderr()
        elseif l:scratch ==# 1
            let l:output = self.stdout()
        endif

        if empty(l:output) && exists('s:scratch_buf')
            call win_execute(bufwinid(s:scratch_buf.bufnr), 'close')
            return
        elseif empty(l:output)
            return
        endif

        call self.create_scratch_buf(a:id, a:data, a:event)
        call setbufline(s:scratch_buf.bufnr, 1, l:output)
        call self.highlight_scratch_buf(a:id, a:data, a:event)

        let s:scratch_buf.completed = 1
        return
    endif

    if (self.scratch ==# 2 && a:event ==# 'stdout') ||
                \ (self.scratch ==# 1 && a:event ==# 'stderr') ||
                \ (self.scratch ># 3)
        return
    endif

    if self.scratch ==# 3
        let l:output = self.both()
        if empty(l:output) | return | endif
        call self.create_scratch_buf(a:id, a:data, a:event)
        call setbufline(s:scratch_buf.bufnr, 1, l:output)
        call self.highlight_scratch_buf(a:id, a:data, a:event)
    else
        let l:output = self[a:event]()
        if empty(l:output) | return | endif
        call self.create_scratch_buf(a:id, a:data, a:event)
        call setbufline(s:scratch_buf.bufnr, 1, l:output)
        call self.highlight_scratch_buf(a:id, a:data, a:event)
    endif
endfunction

function! s:job_handler.create_scratch_buf(id, data, event) abort " {{{1
    if !exists('s:scratch_buf')
        let s:scratch_buf = deepcopy(self.scratch_buf)
    endif

    if !get(s:scratch_buf, 'completed', 1) | return | endif

    let l:title = get(s:scratch_buf,
                \ 'title', '[Output] __' .. join(self.cmd) .. '__')
    if type(l:title) ==# v:t_list
        if a:event ==# 'exit'
            if !a:data
                let l:title = l:title[0]
            else
                let l:title = l:title[1]
            endif
        else
            let l:title = l:title[0]
        endif
    endif

    if !get(s:scratch_buf, 'active', 0)
        let l:cursor_pos = getpos('.')[1:2]
        let l:winid = bufwinid(bufnr('%'))
    endif

    " Re-use the scratch buffer, if it exists
    if get(s:scratch_buf, 'bufnr', -1) >=# 0
        let l:scratch_bufname = bufname(s:scratch_buf.bufnr)

        if bufwinid(s:scratch_buf.bufnr) >=# 0
            call win_gotoid(bufwinid(s:scratch_buf.bufnr))
        else
            execute get(s:scratch_buf, 'height', 10) .. 'split'
                        \ l:scratch_bufname
        endif

        if l:scratch_bufname !=# l:title
            execute 'file!' l:title
        endif

        silent call deletebufline('%', 1, '$')

        call clearmatches(bufwinid(s:scratch_buf.bufnr))

        if !get(s:scratch_buf, 'active', 0)
            call win_gotoid(l:winid)
            call cursor(l:cursor_pos)
        endif

        let s:scratch_buf.completed = 0
        return
    endif

    " Create scratch window and buffer
    execute get(s:scratch_buf, 'height', 10) .. 'split' l:title
    setlocal filetype=joboutput
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
    setlocal fillchars=eob:\ 
    setlocal nonumber

    let s:scratch_buf.bufnr = bufnr('%')

    if !get(s:scratch_buf, 'active', 0)
        call win_gotoid(l:winid)
        call cursor(l:cursor_pos)
    endif

    let s:scratch_buf.completed = 0
endfunction

function! s:job_handler.highlight_scratch_buf(id, data, event) abort dict " {{{1
    if self.scratch ==# 1 | return | endif
    if !exists('s:scratch_buf') | return | endif

    let l:scratch = copy(self.scratch)
    if a:event ==# 'exit'
        if l:scratch ># 3 | let l:scratch -= 3 | endif
    endif

    if l:scratch ==# 2
        let s:scratch_buf.stderr_lines =
                    \ range(1, line('$', bufwinid(s:scratch_buf.bufnr)))
    elseif l:scratch ==# 3
        let s:scratch_buf.stderr_lines = []
        let l:index = 0
        for l:item in self.output
            if l:item.event ==# 'stderr'
                call add(s:scratch_buf.stderr_lines, l:index + 1)
            endif
            let l:index += 1
        endfor
    endif

    if a:event ==# 'exit' && a:data
        call matchaddpos('JobError', s:scratch_buf.stderr_lines,
                    \ 10, -1, {'window': bufwinid(s:scratch_buf.bufnr)})
    else
        call matchaddpos('JobWarning', s:scratch_buf.stderr_lines,
                    \ 10, -1, {'window': bufwinid(s:scratch_buf.bufnr)})
    endif
endfunction

function! s:job_handler.echo_output(id, data, event) abort dict " {{{1
    if !has_key(self, 'cmdheight')
        let self.cmdheight = &cmdheight
    endif

    if a:event ==# 'exit'
        if &cmdheight !=# 1 | set cmdheight-=1 | endif

        let l:msg = copy(self.msg)
        if l:msg ># 3
            let l:msg -= 3
        endif

        if l:msg ==# 3
            let l:output = self.both()
        elseif l:msg ==# 2
            let l:output = self.stderr()
        elseif l:msg ==# 1
            let l:output = self.stdout()
        endif
        if empty(l:output) | return | endif

        mode
        echo join(l:output, "\n") .. "\n"

        let &cmdheight = self.cmdheight
        return
    endif

    if (self.msg ==# 2 && a:event ==# 'stdout') ||
                \ (self.msg ==# 1 && a:event ==# 'stderr') ||
                \ (self.msg ># 3)
        return
    endif

    if self.msg ==# 3
        let l:output = self.both()
        if empty(l:output) | return | endif
        let &cmdheight = len(l:output)
        echo join(l:output, "\n")
    else
        let l:output = self[a:event]()
        if empty(l:output) | return | endif
        let &cmdheight = len(l:output)
        echo join(l:output, "\n")
    endif
    redraw
endfunction

function! s:job_handler.both() abort dict " {{{1
    return map(filter(copy(self.output), '!empty(v:val.event)'),
                \ 'v:val.line')
endfunction

function! s:job_handler.stdout() abort dict " {{{1
    return map(filter(copy(self.output), 'v:val.event ==# "stdout"'),
                \ 'v:val.line')
endfunction

function! s:job_handler.stderr() abort dict " {{{1
    return map(filter(copy(self.output), 'v:val.event ==# "stderr"'),
                \ 'v:val.line')
endfunction

function! s:job_handler.echo_info(job, status, event) abort " {{{1
    redraw
    execute 'echohl' !a:status ? 'JobInfo' : 'JobWarning'
    echo self.info .. ': '
    echohl JobMsg
    echon !a:status ? 'Completed' : 'Failed'
    echohl None
endfunction

function! s:job_handler.start() abort dict " {{{1
    let self.job_id = jobstart(self.cmd, self)
    if get(self, 'sync', 0)
        call jobwait([self.job_id])
    endif
    return self
endfunction

" }}}1

function! shell#get_scratch_buf() abort " {{{1
    return get(s:, 'scratch_buf', {})
endfunction

function! shell#set_scratch_buf(opts) abort " {{{1
    return extend(s:scratch_buf, a:opts)
endfunction

" }}}1

function! shell#compile(cmd, opts = {}) abort " {{{1
    let l:compiler = deepcopy(s:compiler)
    call extend(l:compiler, a:opts)
    let l:compiler.cmd = a:cmd
    return l:compiler.start()
endfunction

function! shell#compiler(opts = {}) abort " {{{1
    return extend(deepcopy(s:compiler), a:opts)
endfunction

" }}}1

let s:compiler = deepcopy(s:job_handler)

function! s:compiler.on_exit(job, status, event) abort dict " {{{1
    if get(self, 'scratch', 0)
        call self.load_scratch_buf(a:job, a:status, a:event)
    endif

    if get(self, 'msg', 0)
        call self.echo_output(a:job, a:status, a:event)
    endif

    call self.on_error(a:job, a:status, a:event)

    if !empty(get(self, 'info', ''))
        call self.echo_info(a:job, a:status, a:event)
    endif

    if has_key(self, 'callback')
        call call(self.callback, [a:job, a:status, a:event])
    endif
endfunction

function! s:compiler.on_error(job, status, event) abort dict " {{{1
    if !empty(&l:errorformat)
        call self.createqflist(a:job, a:status, a:event)
    else
        let self.scratch = 5
        if !exists('self.scratch_buf') | let self.scratch_buf = {} | endif
        let self.scratch_buf.title = get(self.scratch_buf, 'title', [
                    \ '[Warning] __' .. join(self.cmd) .. '__',
                    \ '[Error] __' .. join(self.cmd) .. '__',
                    \ ])
        call self.load_scratch_buf(a:job, a:status, a:event)
    endif
endfunction

function! s:compiler.createqflist(job, status, event) abort dict " {{{1
    if get(self, 'qf_autojump', 0)
        silent cexpr self.both()
    else
        silent cgetexpr self.both()
    endif

    if !exists('self.qf_win') | let self.qf_win = {} | endif
    if get(self.qf_win, 'active', 1)
        call setqflist(filter(getqflist(), 'v:val.valid !=# 0'))
        if empty(getqflist()) | return | endif

        if !empty(get(self.qf_win, 'title', ''))
            call setqflist([], 'a', {'title': self.qf_win.title})
        endif

        if get(self.qf_win, 'active', 1) ==# 1
            let l:cursor_pos = getpos('.')[1:2]
            let l:winid = bufwinid(bufnr('%'))
        endif

        execute 'cwindow ' .. get(self.qf_win, 'height', '')

        if get(self.qf_win, 'active', 1) ==# 1
            call win_gotoid(l:winid)
            call cursor(l:cursor_pos)
        endif
    endif
endfunction

" }}}1
