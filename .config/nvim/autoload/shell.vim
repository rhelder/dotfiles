" [TODO]
" * highlight messages
" * print to scratch buffer
" * option to not focus on qf window

function! shell#jobstart(cmd, opts = {}) abort " {{{1
    let l:job_handler = deepcopy(s:job_handler)
    call extend(l:job_handler, a:opts)
    return l:job_handler.start(a:cmd)
endfunction

function! shell#job_handler() abort " {{{1
    return s:job_handler
endfunction

" }}}1

function! s:on_output(job_id, data, event) abort dict " {{{1
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

    if has_key(self, 'callback')
        call call(function(self.callback), [a:job_id, a:data, a:event])
    endif
endfunction

" }}}1

let s:job_handler = {
            \ 'on_stdout': function('s:on_output'),
            \ 'on_stderr': function('s:on_output'),
            \ }

function! s:job_handler.on_exit(job_id, exit_status, event) abort dict " {{{1
    if get(self, 'msg', 0)
        call self.print_msg(a:event)
    endif

    if has_key(self, 'qf')
        call self.createqflist()
    endif

    if has_key(self, 'callback')
        call call(function(self.callback), [a:job_id, a:exit_status, a:event])
    endif
endfunction

function! s:job_handler.print_msg(event) abort dict " {{{1
    if !has_key(self, 'cmdheight')
        let self.cmdheight = &cmdheight
    endif

    if a:event ==# 'exit'
        if &cmdheight !=# 1 | set cmdheight-=1 | endif
        if self.msg ==# 3
            let l:msg = self.both
        elseif self.msg ==# 2
            let l:msg = self.stderr
        elseif self.msg ==# 1
            let l:msg = self.stdout
        endif
        if l:msg ==# [''] | return | endif

        mode
        if get(self, 'sync', 0)
            echo join(l:msg, "\n")
        else
            echo join(l:msg, "\n") .. "\n"
        endif

        let &cmdheight = self.cmdheight
        return
    endif

    if (self.msg ==# 2 && a:event ==# 'stdout') ||
                \ (self.msg ==# 1 && a:event ==# 'stderr')
        return
    endif

    if self.msg ==# 3
        let &cmdheight = len(self.both)
        echo join(self.both, "\n")
    else
        let &cmdheight = len(self[a:event])
        echo join(self[a:event], "\n")
    endif
    redraw
endfunction

function! s:job_handler.createqflist() abort dict " {{{1
    silent cexpr self.both
    if get(self.qf, 'window', 0)
        call setqflist(filter(getqflist(), 'v:val.valid !=# 0'))
        if !empty(get(self.qf, 'title', ''))
            call setqflist([], 'a', {'title': self.qf.title})
        endif
        execute 'cwindow ' .. get(self.qf, 'height', '')
    endif
endfunction

function! s:job_handler.start(cmd) abort " {{{1
    let self.job_id = jobstart(a:cmd, self)
    if get(self, 'sync', 0)
        call jobwait([self.job_id])
    endif
    return self
endfunction

" }}}1
