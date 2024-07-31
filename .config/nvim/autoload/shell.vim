" [TODO]
" * highlight messages
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
        call self.set_scratch_buf(a:channel, a:data, a:event)
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
        call self.set_scratch_buf(a:job, a:status, a:event)
    endif

    if get(self, 'msg', 0)
        call self.print_msg(a:job, a:status, a:event)
    endif

    if has_key(self, 'callback')
        call call(self.callback, [a:job, a:status, a:event])
    endif
endfunction

function! s:job_handler.set_scratch_buf(id, data, event) abort dict " {{{1
    let l:cmd = self.cmd
    if type(self.cmd) ==# v:t_list
        let l:cmd = join(self.cmd)
    endif
    let l:cmd = substitute(l:cmd, '\W', '_', 'g')

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
        if l:output ==# [''] | return | endif

        call self.create_scratch_buf(l:cmd, a:id, a:data, a:event)
        call setbufline(b:{l:cmd}_scratch_buf.bufnr, 1, l:output)

        let b:{l:cmd}_scratch_buf.completed = 1
        return
    endif

    if (self.scratch ==# 2 && a:event ==# 'stdout') ||
                \ (self.scratch ==# 1 && a:event ==# 'stderr') ||
                \ (self.scratch ># 3)
        return
    endif

    if self.scratch ==# 3
        if empty(self.both) | return | endif
        call self.create_scratch_buf(l:cmd, a:id, a:data, a:event)
        call setbufline(b:{l:cmd}_scratch_buf.bufnr, 1, self.both)
    else
        if empty(self[a:event]) | return | endif
        call self.create_scratch_buf(l:cmd, a:id, a:data, a:event)
        call setbufline(b:{l:cmd}_scratch_buf.bufnr, 1, self[a:event])
    endif
endfunction

function! s:job_handler.create_scratch_buf(cmd, id, data, event) abort " {{{1
    if !exists('b:' .. a:cmd .. '_scratch_buf')
        let b:{a:cmd}_scratch_buf = deepcopy(self.scratch_win)
    endif

    if !get(b:{a:cmd}_scratch_buf, 'completed', 1) | return | endif

    let l:title = get(b:{a:cmd}_scratch_buf, 'title', '[Scratch] ' .. a:cmd)
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

    let l:pos = getpos('.')

    if get(b:{a:cmd}_scratch_buf, 'bufnr', -1) >=# 0
        let l:scratch_bufwinnr = bufwinnr(b:{a:cmd}_scratch_buf.bufnr)
        let l:scratch_bufname = bufname(b:{a:cmd}_scratch_buf.bufnr)

        if l:scratch_bufwinnr ==# -1
            execute get(b:{a:cmd}_scratch_buf, 'height', 10) .. 'split'
                        \ l:scratch_bufname
        else
            execute l:scratch_bufwinnr .. 'wincmd w'
        endif

        if l:scratch_bufname !=# l:title
            if buflisted(bufnr(l:title))
                let l:title ..= '(' .. bufname(l:pos[0]) .. ')'
            endif
            execute 'file!' l:title
        endif

        silent call deletebufline('%', 1, '$')

        execute bufwinnr(l:pos[0]) .. 'wincmd w'
        call cursor(l:pos[1:2])
        let b:{a:cmd}_scratch_buf.completed = 0
        return
    endif

    if buflisted(bufnr(l:title))
        let l:title ..= '(' .. bufname('%') .. ')'
    endif

    execute get(b:{a:cmd}_scratch_buf, 'height', 10) .. 'split' l:title
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
    silent call deletebufline('%', 1, '$')

    let l:bufnr = bufnr('%')

    execute bufwinnr(l:pos[0]) .. 'wincmd w'
    call cursor(l:pos[1:2])

    let b:{a:cmd}_scratch_buf.bufnr = l:bufnr
    let b:{a:cmd}_scratch_buf.completed = 0
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
        let &cmdheight = len(self.both)
        echo join(self.both, "\n")
    else
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
    let l:compiler.callback = get(l:compiler, 'createqflist')
    call extend(l:compiler, a:opts)
    return l:compiler.start(a:cmd)
endfunction

" }}}1

let s:compiler = extend(deepcopy(s:job_handler), {'qf': {}})
function! s:compiler.createqflist(job, status, event) abort dict " {{{1
    if a:event !=# 'exit' | return | endif

    silent cexpr self.both
    if get(self.qf, 'window', 0)
        call setqflist(filter(getqflist(), 'v:val.valid !=# 0'))
        if !empty(get(self.qf, 'title', ''))
            call setqflist([], 'a', {'title': self.qf.title})
        endif
        execute 'cwindow ' .. get(self.qf, 'height', '')
    endif
endfunction

" }}}1
