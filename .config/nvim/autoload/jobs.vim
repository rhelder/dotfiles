function! jobs#jobstart(cmd, opts = {}) abort " {{{1
  let l:job_controller = deepcopy(s:job_controller)
  call extend(l:job_controller, {
        \ 'name': 'Job',
        \ 'on_start': l:job_controller.notify_on_start,
        \ 'on_exit': l:job_controller.notify_on_exit,
        \ 'on_stdout': l:job_controller.on_output,
        \ 'on_stderr': l:job_controller.on_output,
        \ })
  call extend(l:job_controller, a:opts)
  let l:job_controller.cmd = a:cmd
  let l:job_controller.scratch_buf.cmd = a:cmd
  return l:job_controller.start()
endfunction

function! jobs#call_callbacks(funcnames, job, data, event) abort dict " {{{1
  for l:funcname in a:funcnames
    call self[l:funcname](a:job, a:data, a:event)
  endfor
endfunction

" }}}1

let s:job_controller = {}

function! s:job_controller.start() abort dict " {{{1
  let self.job_id = jobstart(self.cmd, self)

  if !empty(get(self, 'on_start', ''))
    call self.on_start(self.job_id, [], 'start')
  endif

  if get(self, 'sync', 0)
    call jobwait([self.job_id])
  endif

  return self
endfunction

function! s:job_controller.notify_on_start(job, data, event) abort dict " {{{1
  redraw
  echohl JobInfo
  echo self.name .. ': '
  echohl JobMsg
  echon 'Started'
  echohl None
endfunction

function! s:job_controller.notify_on_exit(job, status, event) abort dict " {{{1
  redraw
  execute 'echohl' !a:status ? 'JobInfo' : 'JobWarning'
  echo self.name .. ': '
  echohl JobMsg
  echon !a:status ? 'Completed' : 'Failed'
  echohl None
endfunction

function! s:job_controller.on_output(job, data, event) abort dict " {{{1
  if !has_key(self, 'output')
    let self.output = [{'line': '', 'event': ''}]
  endif

  " The first element of 'a:data' always continues a previous line. Concatenate
  " with last element of previous output.
  let self.output[-1].line ..= a:data[0]
  let self.output[-1].event = a:event

  " If 'a:data' has more than one element, the first element completes the
  " previous line, and each subsequent element starts a new line. Return
  " completed lines or an empty string
  if len(a:data) < 2 | return '' | endif

  let l:output = [self.output[-1].line]

  for l:line in a:data[1:-2]
    call add(self.output, {'line': l:line, 'event': a:event})
    call add(l:output, self.output[-1].line)
  endfor

  " The last element of 'a:data' will be continued by the first element of
  " 'a:data' the next time 's:on_output' is called. The value of 'event' will
  " be determined then.
  call add(self.output, {'line': a:data[-1], 'event': ''})

  return l:output
endfunction

" }}}1

function! s:job_controller.scratch_on_output(id, data, event) abort dict " {{{1
  let l:output = self.on_output(a:id, a:data, a:event)

  if a:data ==# ['']
    if map(filter(copy(self.output), 'v:val.event ==# ' .. string(a:event)),
          \ 'v:val.line') ==# ['']
      let self.scratch_buf.empty = 1
    else
      let self.scratch_buf.empty = 0
    endif
  endif

  if empty(l:output) | return | endif

  if has_key(self.scratch_buf, 'bufnr')
    return appendbufline(self.scratch_buf.bufnr, '$', l:output)
  endif

  call self.scratch_buf.init(self.cmd)
  return setbufline(self.scratch_buf.bufnr, 1, l:output)
endfunction

function! s:job_controller.scratch_on_exit(job, status, event) abort dict " {{{1
  if self.scratch_buf.empty
    let l:title = '[Job Output] '
          \ .. s:get_title(get(self.scratch_buf, 'title', ''), self.cmd)
    let l:bufnr = bufnr(l:title)
    " 'win_execute()' throws no error if no window, so no need to check
    call win_execute(bufwinid(l:bufnr), 'close')
    return
  endif

  let l:stderr_lines = map(copy(self.output),
        \ 'v:val.event ==# "stderr" ? v:key : 0')
  let l:stderr_lines = filter(l:stderr_lines, 'v:val >=# 0')
  if a:status
    call matchaddpos('JobError', l:stderr_lines,
          \ 10, -1, {'window': bufwinid(self.scratch_buf.bufnr)})
  else
    call matchaddpos('JobWarning', l:stderr_lines,
          \ 10, -1, {'window': bufwinid(self.scratch_buf.bufnr)})
  endif
endfunction

" }}}1

let s:job_controller.scratch_buf = {}

function! s:job_controller.scratch_buf.init(cmd) abort dict " {{{1
  let self.title = '[Job Output] '
        \ .. s:get_title(get(self, 'title', ''), a:cmd)
  let self.bufwinheight = get(self, 'bufwinheight', 10)

  let l:cursor_pos = getpos('.')[1:2]
  let l:cursor_win = win_getid()

  if !bufexists(self.title) " Create new scratch buffer
    execute self.bufwinheight .. 'split' self.title
    setlocal filetype=joboutput
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
    setlocal fillchars=eob:\ 
    setlocal nonumber
    let self.bufnr = bufnr(self.title)

  else " Reuse existing scratch buffer
    let self.bufnr = bufnr(self.title)
    if bufwinid(self.bufnr) <# 0
      execute self.bufwinheight .. 'split' self.title
    endif

    call win_execute(bufwinid(self.bufnr), [
          \ 'resize ' .. self.bufwinheight,
          \ ])

    silent call deletebufline(self.bufnr, 1, '$')
    call clearmatches(bufwinid(self.bufnr))
  endif

  call win_gotoid(l:cursor_win)
  call cursor(l:cursor_pos)
endfunction

" }}}1

function! s:job_controller.quickfix_on_exit(job, status, event) abort dict " {{{1
  " Only create new qf list if the current list is not associated with this job
  if !exists('self.qflist') | let self.qflist = {} | endif
  let l:title = s:get_title(get(self.qflist, 'title', ''), self.cmd)
  if getqflist({'title': 0}).title !=# l:title
    call setqflist([])
  else
    call setqflist([], 'r')
  endif

  silent caddexpr map(copy(self.output), 'v:val.line')
  call setqflist(filter(getqflist(), 'v:val.valid !=# 0'), 'r')
  call setqflist([], 'a', {'title': l:title})

  let l:cursor_pos = getpos('.')[1:2]
  let l:winid = bufwinid(bufnr('%'))
  botright cwindow
  call win_gotoid(l:winid)
  call cursor(l:cursor_pos)
endfunction

" }}}1

function! s:get_title(title, cmd) abort " {{{1
  if empty(a:title)
    return type(a:cmd) ==# v:t_list
          \ ? join(a:cmd)
          \ : a:cmd
  else
    return a:title
  endif
endfunction

" }}}1
