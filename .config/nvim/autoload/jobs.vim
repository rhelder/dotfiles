function! jobs#jobstart(cmd, opts = {}) abort " {{{1
  let l:job_controller = deepcopy(s:job_controller)

  call extend(l:job_controller, {
        \ 'cmd': a:cmd,
        \ 'name': 'Job',
        \ 'on_start': get(l:job_controller, 'notify_on_start'),
        \ 'on_exit': get(l:job_controller, 'notify_on_exit'),
        \ })
  call extend(l:job_controller, a:opts)
  call extend(get(l:job_controller, 'scratch_buf', {}), s:scratch_buf)

  return l:job_controller.start()
endfunction

function! jobs#call(funcnames, job, data, event) abort dict " {{{1
  if type(a:funcnames) ==# v:t_string
    call self[a:funcnames](a:job, a:data, a:event)
    return
  endif

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

  let l:stderr_lnums = map(copy(self.output),
        \ 'v:val.event ==# "stderr" ? v:key + 1 : 0')
  let l:stderr_lnums = filter(l:stderr_lnums, 'v:val ># 0')

  if a:status
    call matchaddpos('JobError', l:stderr_lnums,
          \ 10, -1, {'window': bufwinid(self.scratch_buf.bufnr)})
  else
    call matchaddpos('JobWarning', l:stderr_lnums,
          \ 10, -1, {'window': bufwinid(self.scratch_buf.bufnr)})
  endif
endfunction

" }}}1

let s:scratch_buf = {}

function! s:scratch_buf.init(cmd) abort dict " {{{1
  let self.title = '[Job Output] '
        \ .. s:get_title(get(self, 'title', ''), a:cmd)
  let self.bufwinheight = get(self, 'bufwinheight', 10)

  let l:cursor_pos = getpos('.')[1:2]
  let l:cursor_win = win_getid()

  if !bufexists(self.title) " Create new scratch buffer
    execute self.bufwinheight .. 'split' self.title
    let self.bufnr = bufnr(self.title)

    setlocal filetype=joboutput
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
    setlocal winfixheight
    setlocal fillchars=eob:\ 
    setlocal nonumber
    setlocal nolist

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

  if get(self.qflist, 'all', 1)
    " Because 's:qftext()' returns the text of non-valid entries, that means
    " that the default format will be used to display any entries with 'text'
    " equal to an empty string. Remove entries with an empty 'text'.
    call setqflist(filter(getqflist(), '!empty(v:val.text)'), 'r')
  else
    call setqflist(filter(getqflist(), 'v:val.valid'), 'r')
  endif

  call setqflist([], 'a', {
        \ 'title': l:title,
        \ 'quickfixtextfunc': function('s:qftext'),
        \ })

  let l:cursor_pos = getpos('.')[1:2]
  let l:winid = bufwinid(bufnr('%'))

  botright cwindow
  setlocal nolist

  call win_gotoid(l:winid)
  call cursor(l:cursor_pos)
endfunction

function! s:qftext(info) abort " {{{2
  let l:items = getqflist({'id': a:info.id, 'items': 0}).items
  let l:list = []

  for l:item in l:items
    if l:item.valid
      call add(l:list, '')
    else
      call add(l:list, l:item.text)
    endif
  endfor

  return l:list
endfunction
" }}}2

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
