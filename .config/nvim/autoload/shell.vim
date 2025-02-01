" Todo:
" * Rename to job_controller
" * Rename to jobs instead of shell
" * Test quickfix

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
  let l:output = self.on_output(a:id, a:data, a:event)
  if empty(l:output) | return | endif

  if !exists('s:scratch_buf')
    let s:scratch_buf = {}
  endif

  if get(s:scratch_buf, 'job_id', 0) ==# self.job_id
    return appendbufline(s:scratch_buf.bufnr, '$', l:output)
  endif

  call self.scratch_buf_init()
  return setbufline(s:scratch_buf.bufnr, 1, l:output)
endfunction

function! s:job_handler.scratch_buf_init() abort dict " {{{2
  call extend(s:scratch_buf, self.scratch_buf)
  let s:scratch_buf.job_id = self.job_id
  if empty(get(s:scratch_buf, 'title', ''))
    let s:scratch_buf.title =
          \ '[Output] ' .. type(self.cmd) ==# v:t_list
          \   ? join(self.cmd)
          \   : self.cmd
  endif

  " 'title' can be a list. The first element will be the title of the bufer if
  " the exit status is 0, and the second element will be the title if the exit
  " status is 1. For now, use the first element.
  let l:title = type(s:scratch_buf.title) ==# v:t_list
        \ ? s:scratch_buf.title[0]
        \ : s:scratch_buf.title

  let l:cursor_pos = getpos('.')[1:2]
  let l:cursor_win = bufwinid(bufnr('%'))

  if !has_key(s:scratch_buf, 'bufnr') " Create new scratch buffer
    execute get(s:scratch_buf, 'bufwinheight', 10) .. 'split' l:title
    setlocal filetype=joboutput
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
    setlocal fillchars=eob:\ 
    setlocal nonumber

    let s:scratch_buf.bufnr = bufnr('%')

  else " Reuse existing scratch buffer
    if bufwinid(s:scratch_buf.bufnr) <# 0
      execute get(s:scratch_buf, 'bufwinheight', 10)
            \ .. 'split' bufname(s:scratch_buf.bufnr)
    endif

    if bufname(s:scratch_buf.bufnr) !=# l:title
      call win_execute(bufwinid(s:scratch_buf.bufnr), [
            \ 'resize ' .. get(s:scratch_buf, 'bufwinheight', 10),
            \ 'file! ' .. l:title,
            \ ])
    endif

    silent call deletebufline(s:scratch_buf.bufnr, 1, '$')
    call clearmatches(bufwinid(s:scratch_buf.bufnr))
  endif

  call win_gotoid(l:cursor_win)
  call cursor(l:cursor_pos)
endfunction
" }}}2

function! shell#scratch_on_exit(job, status, event) abort dict " {{{1
  if !exists('s:scratch_buf') || bufwinid(s:scratch_buf.bufnr) <# 0
    return
  endif

  if empty(self.output)
    return win_execute(bufwinid(s:scratch_buf.bufnr), 'close')
  endif

  if a:status && type(s:scratch_buf.title) ==# v:t_list
    call win_execute(bufwinid(s:scratch_buf.bufnr),
          \ 'file! ' .. s:scratch_buf.title[1])
  endif

  let l:stderr_lines = map(self.output,
        \ 'v:val.event ==# "stderr" ? v:key : 0')
  let l:stderr_lines = filter(l:stderr_lines, 'v:val >=# 0')
  if a:status
    call matchaddpos('JobError', l:stderr_lines,
          \ 10, -1, {'window': bufwinid(s:scratch_buf.bufnr)})
  else
    call matchaddpos('JobWarning', l:stderr_lines,
          \ 10, -1, {'window': bufwinid(s:scratch_buf.bufnr)})
  endif
endfunction

function! shell#get_scratch_buf() abort " {{{1
  return get(s:, 'scratch_buf', {})
endfunction

function! shell#set_scratch_buf(opts) abort " {{{1
  return extend(s:scratch_buf, a:opts)
endfunction

" }}}1

function! shell#output_to_quickfix(job, status, event) abort dict " {{{1
  silent cgetexpr map(self.output, 'v:val.line')
  call setqflist(filter(getqflist(), 'v:val.valid !=# 0'))
  if empty(getqflist()) | return | endif

  if !exists('self.qflist') | let self.qflist = {} | endif
  if !empty(get(self.qflist, 'title', ''))
    call setqflist([], 'a', {'title': self.qflist.title})
  endif

  let l:cursor_pos = getpos('.')[1:2]
  let l:winid = bufwinid(bufnr('%'))
  cwindow
  call win_gotoid(l:winid)
  call cursor(l:cursor_pos)
endfunction

" }}}1
