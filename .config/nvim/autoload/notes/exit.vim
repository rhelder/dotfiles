function! notes#exit#compile() abort " {{{1
  let l:input = expand('<afile>')
  if !filereadable(l:input) | return | endif

  let l:output = expand('<afile>:r' .. '.html')
  if filereadable(l:output)
        \ && getftime(l:output) ># getftime(l:input)
    return
  endif

  let l:pandoc_cmd = [
        \ 'pandoc',
        \ '--defaults=notes',
        \ '--output=' .. l:output,
        \ l:input,
        \ ]

  let l:opts = {
        \ 'on_stderr': function('jobs#call', ['scratch_on_output']),
        \ 'on_exit':
        \   function('jobs#call', [['scratch_on_exit', 'notify_on_exit']]),
        \ }

  if string(v:exiting) ==# 'v:null'
    call jobs#jobstart(l:pandoc_cmd,
          \ extend(copy(l:opts), {
          \ 'name': 'Pandoc',
          \ 'scratch_buf': {'title': 'Pandoc'},
          \ }))

    call jobs#jobstart(['build-index'],
          \ extend(copy(l:opts), {
          \ 'name': 'build-index',
          \ 'scratch_buf': {'title': 'build-index'},
          \ }))

  else
    call jobs#jobstart(l:pandoc_cmd, {
          \ 'sync': 1,
          \ 'name': 'Pandoc',
          \ 'scratch_buf': {'title': 'Pandoc'},
          \ })

    call jobs#jobstart({['build-index'], {
          \ 'sync': 1,
          \ 'name': 'build-index',
          \ 'scratch_buf': {'title': 'build-index'},
          \ })
  endif
endfunction

" }}}1
