" Todo:
" * Rename to job_controller
" * Rename to jobs instead of shell
" * Notify user on job start

function! shell#jobstart(cmd, opts = {}) abort " {{{1
  let l:job_handler = deepcopy(s:job_handler)
  call extend(l:job_handler, {
        \ 'on_stdout': l:job_handler.on_output,
        \ 'on_stderr': l:job_handler.on_output,
        \ 'on_exit': function('shell#notify_on_exit'),
        \ 'name': 'Job',
        \ })
  call extend(l:job_handler, a:opts)
  let l:job_handler.cmd = a:cmd
  return l:job_handler.start()
endfunction

" }}}1

let s:job_handler = {}

function! s:job_handler.start() abort dict " {{{1
  let self.job_id = jobstart(self.cmd, self)
  if get(self, 'sync', 0)
    call jobwait([self.job_id])
  endif
  return self
endfunction

function! s:job_handler.on_output(job, data, event) abort dict " {{{1
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

function! shell#notify_on_exit(job, status, event) abort dict " {{{1
  redraw
  execute 'echohl' !a:status ? 'JobInfo' : 'JobWarning'
  echo self.name .. ': '
  echohl JobMsg
  echon !a:status ? 'Completed' : 'Failed'
  echohl None
endfunction

" }}}1

function! shell#scratch_on_output(id, data, event) abort dict " {{{1
  if !has_key(self, 'scratch_buf') | let self.scratch_buf = {} | endif

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

  call self.scratch_buf_init()
  return setbufline(self.scratch_buf.bufnr, 1, l:output)
endfunction

function! s:job_handler.scratch_buf_init() abort dict " {{{2
  let self.scratch_buf.title =
        \ '[Job Output] ' .. self.title(get(self.scratch_buf, 'title', ''))
  let self.scratch_buf.bufwinheight = get(self.scratch_buf, 'bufwinheight', 10)

  let l:cursor_pos = getpos('.')[1:2]
  let l:cursor_win = win_getid()

  if !bufexists(self.scratch_buf.title) " Create new scratch buffer
    execute self.scratch_buf.bufwinheight .. 'split' self.scratch_buf.title
    setlocal filetype=joboutput
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
    setlocal fillchars=eob:\ 
    setlocal nonumber
    let self.scratch_buf.bufnr = bufnr(self.scratch_buf.title)

  else " Reuse existing scratch buffer
    let self.scratch_buf.bufnr = bufnr(self.scratch_buf.title)
    if bufwinid(self.scratch_buf.bufnr) <# 0
      execute self.scratch_buf.bufwinheight .. 'split' self.scratch_buf.title
    endif

    call win_execute(bufwinid(self.scratch_buf.bufnr), [
          \ 'resize ' .. self.scratch_buf.bufwinheight,
          \ ])

    silent call deletebufline(self.scratch_buf.bufnr, 1, '$')
    call clearmatches(bufwinid(self.scratch_buf.bufnr))
  endif

  call win_gotoid(l:cursor_win)
  call cursor(l:cursor_pos)
endfunction
" }}}2

function! shell#scratch_on_exit(job, status, event) abort dict " {{{1
  if self.scratch_buf.empty
    let l:title =
          \ '[Job Output] ' .. self.title(get(self.scratch_buf, 'title', ''))
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

function! shell#output_to_quickfix(job, status, event) abort dict " {{{1
  " Only create new qf list if the current list is not associated with this job
  if !exists('self.qflist') | let self.qflist = {} | endif
  let l:title = self.title(get(self.qflist, 'title', ''))
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

function! s:job_handler.title(title) abort dict " {{{1
  if empty(a:title)
    return type(self.cmd) ==# v:t_list
          \ ? join(self.cmd)
          \ : self.cmd
  else
    return a:title
  endif
endfunction

" }}}1
