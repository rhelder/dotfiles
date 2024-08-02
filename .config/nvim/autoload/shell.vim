" [TODO]
" * highlight messages
" * option to focus on scratch buffer window
" * option to not focus on qf window

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

function! s:on_output(channel, data, event) abort dict " {{{1
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

    if get(self, 'scratch', 0) && len(a:data) > 1
        call self.load_scratch_buf(a:channel, a:data, a:event)
    endif

    if get(self, 'msg', 0) && len(a:data) > 1
        call self.print_msg(a:channel, a:data, a:event)
    endif

    " Add last element of a:data to list; it may be concatenated with the first
    " element of a:data the next time the function is called
    if len(a:data) > 1
        call add(self[a:event], a:data[-1])
        call add(self.both, a:data[-1])
    endif

    if has_key(self, 'callback')
        call call(self.callback, [a:channel, a:data, a:event])
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
        call self.print_msg(a:job, a:status, a:event)
    endif

    if has_key(self, 'callback')
        call call(self.callback, [a:job, a:status, a:event])
    endif
endfunction

function! s:job_handler.load_scratch_buf(id, data, event) abort dict " {{{1
    if !exists('self.scratch_win') | let self.scratch_win = {} | endif

    if a:event ==# 'exit'
        let l:scratch = self.scratch
        if l:scratch ># 3 | let l:scratch -= 3 | endif

        if l:scratch ==# 3
            let l:output = self.both
        elseif l:scratch ==# 2
            let l:output = self.stderr
        elseif l:scratch ==# 1
            let l:output = self.stdout
        endif

        if l:output ==# [''] && exists('s:scratch_win')
            call win_execute(bufwinid(s:scratch_win.bufnr), 'close')
            unlet s:scratch_win
            return
        elseif l:output ==# ['']
            return
        endif

        call self.create_scratch_win(a:id, a:data, a:event)
        call setbufline(s:scratch_win.bufnr, 1, l:output)

        let s:scratch_win.completed = 1
        return
    endif

    if (self.scratch ==# 2 && a:event ==# 'stdout') ||
                \ (self.scratch ==# 1 && a:event ==# 'stderr') ||
                \ (self.scratch ># 3)
        return
    endif

    if self.scratch ==# 3
        if empty(self.both) | return | endif
        call self.create_scratch_win(a:id, a:data, a:event)
        call setbufline(s:scratch_win.bufnr, 1, self.both)
    else
        if empty(self[a:event]) | return | endif
        call self.create_scratch_win(a:id, a:data, a:event)
        call setbufline(s:scratch_win.bufnr, 1, self[a:event])
    endif
endfunction

function! s:job_handler.create_scratch_win(id, data, event) abort " {{{1
    if !exists('s:scratch_win')
        let s:scratch_win = deepcopy(self.scratch_win)
    endif

    if !get(s:scratch_win, 'completed', 1) | return | endif

    let l:title = get(s:scratch_win, 'title', '[Output] ' .. join(self.cmd))
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

    let l:cursor_pos = getpos('.')[1:2]
    let l:winid = bufwinid(bufnr('%'))

    " Re-use the scratch buffer, if it exists
    if get(s:scratch_win, 'bufnr', -1) >=# 0
        let l:scratch_bufwinid = bufwinid(s:scratch_win.bufnr)
        let l:scratch_bufname = bufname(s:scratch_win.bufnr)

        if l:scratch_bufwinid >=# 0
            call win_gotoid(l:scratch_bufwinid)
        else
            execute get(s:scratch_win, 'height', 10) .. 'split'
                        \ l:scratch_bufname
        endif

        if l:scratch_bufname !=# l:title
            execute 'file!' l:title
        endif

        silent call deletebufline('%', 1, '$')

        call win_gotoid(l:winid)
        call cursor(l:cursor_pos)
        let s:scratch_win.completed = 0
        return
    endif

    " Create scratch window and buffer
    execute get(s:scratch_win, 'height', 10) .. 'split' l:title
    setlocal filetype=joboutput
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile

    let s:scratch_win.bufnr = bufnr('%')

    call win_gotoid(l:winid)
    call cursor(l:cursor_pos)
    let s:scratch_win.completed = 0
endfunction

function! s:job_handler.print_msg(id, data, event) abort dict " {{{1
    if !has_key(self, 'cmdheight')
        let self.cmdheight = &cmdheight
    endif

    if a:event ==# 'exit'
        if &cmdheight !=# 1 | set cmdheight-=1 | endif

        let l:msg = self.msg
        if l:msg ># 3
            let l:msg -= 3
        endif

        if l:msg ==# 3
            let l:output = self.both
        elseif l:msg ==# 2
            let l:output = self.stderr
        elseif l:msg ==# 1
            let l:output = self.stdout
        endif
        if l:output ==# [''] | return | endif

        mode
        if get(self, 'sync', 0)
            echo join(l:output, "\n")
        else
            echo join(l:output, "\n") .. "\n"
        endif

        let &cmdheight = self.cmdheight
        return
    endif

    if (self.msg ==# 2 && a:event ==# 'stdout') ||
                \ (self.msg ==# 1 && a:event ==# 'stderr') ||
                \ (self.msg ># 3)
        return
    endif

    if self.msg ==# 3
        if empty(self.both) | return | endif
        let &cmdheight = len(self.both)
        echo join(self.both, "\n")
    else
        if empty(self[a:event]) | return | endif
        let &cmdheight = len(self[a:event])
        echo join(self[a:event], "\n")
    endif
    redraw
endfunction

function! s:job_handler.start() abort dict " {{{1
    let self.job_id = jobstart(self.cmd, self)
    if get(self, 'sync', 0)
        call jobwait([self.job_id])
    endif
    return self
endfunction

" }}}1

function! shell#compile(cmd, opts = {}) abort " {{{1
    let l:compiler = deepcopy(s:compiler)
    call extend(l:compiler, a:opts)
    let l:compiler.cmd = a:cmd
    return l:compiler.start()
endfunction

" }}}1

let s:compiler = deepcopy(s:job_handler)

function! s:compiler.on_exit(job, status, event) abort dict " {{{1
    if get(self, 'scratch', 0)
        call self.load_scratch_buf(a:job, a:status, a:event)
    endif

    if get(self, 'msg', 0)
        call self.print_msg(a:job, a:status, a:event)
    endif

    call self.on_error(a:job, a:status, a:event)

    if has_key(self, 'callback')
        call call(self.callback, [a:job, a:status, a:event])
    endif
endfunction

function! s:compiler.on_error(job, status, event) abort dict " {{{1
    if !empty(&l:errorformat)
        call self.createqflist(a:job, a:status, a:event)
    else
        let self.scratch = 5
        let self.scratch_win = {
                    \ 'title': [
                    \   '[Warning] ' .. join(self.cmd),
                    \   '[Error] ' .. join(self.cmd),
                    \ ],
                    \ }
        call self.load_scratch_buf(a:job, a:status, a:event)
    endif
endfunction

function! s:compiler.createqflist(job, status, event) abort dict " {{{1
    if a:event !=# 'exit' | return | endif

    if !exists('self.qf_win') | let self.qf_win = {} | endif

    silent cexpr self.both
    if get(self.qf_win, 'window', 0)
        call setqflist(filter(getqflist(), 'v:val.valid !=# 0'))
        if !empty(get(self.qf_win, 'title', ''))
            call setqflist([], 'a', {'title': self.qf_win.title})
        endif
        execute 'cwindow ' .. get(self.qf_win, 'height', '')
    endif
endfunction

" }}}1
