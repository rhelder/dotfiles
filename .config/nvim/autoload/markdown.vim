function! markdown#pandoc(args, bang) abort " {{{1
  let l:cmd = ['pandoc']

  let l:args = split(a:args)
  if empty(l:args) || l:args[0][0] ==# '-'
    call insert(l:args, 'html', 0)
  endif
  let l:output_fmt = l:args[0]
  let l:args[0] = '--to=' .. l:args[0]
  call extend(l:cmd, l:args)

  let l:output_file = expand('%:r') .. '.' .. l:output_fmt
  call add(l:cmd, '--output=' .. l:output_file)
  call add(l:cmd, expand('%'))

  call jobs#jobstart(l:cmd, {
        \ 'name': 'Pandoc',
        \ 'on_stderr':
        \   function('jobs#call_callbacks', [['scratch_on_output']]),
        \ 'on_exit': function('s:on_exit', [empty(a:bang)
        \   ? ''
        \   : l:output_file]),
        \ 'scratch_buf': {'title': 'Pandoc', 'bufwinheight': 5},
        \ })
endfunction

function! s:on_exit(output_file, job, status, event) abort dict " {{{2
  call self.scratch_on_exit(a:job, a:status, a:event)
  call self.notify_on_exit(a:job, a:status, a:event)

  if !empty(a:output_file)
    call jobs#jobstart(['open', a:output_file], {
          \ 'on_start': '',
          \ 'on_exit': '',
          \ })
  endif
endfunction
" }}}2

" }}}1
