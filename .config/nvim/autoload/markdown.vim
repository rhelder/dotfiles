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

function! markdown#omnifunc(findstart, base) abort " {{{1
  if a:findstart
    if exists('s:completer') | unlet s:completer | endif

    " Subtract by one to align with index of l:line
    let l:start = col('.') - 1
    " Set l:line equal to the portion of the line behind the cursor
    let l:line = getline('.')[:l:start-1]

    for l:completer in s:completers
      if !completer.in_context(l:line) | continue | endif

      let s:completer = l:completer
      return l:completer.find_start(l:start, l:line)
    endfor
    return -3

  elseif !exists('s:completer')
    return []
  endif

  return s:completer.complete(a:base)
endfunction

" Citation completer {{{1

let s:completer_citations = {}

function! s:completer_citations.in_context(line) abort dict " {{{2
  if s:in_yaml_block()
    return 0
  endif

  if a:line =~# '\v(^|\[|\s)\@%(\w%([:.#$%&-+?<>~/]?\w)*)*$'
    let self.start_pattern = '\v%(^|\s|\[|-)\@$'
    return 1
  elseif a:line =~# '\v(^|\[|\s)\@\{.*'
    let self.start_pattern = '\v%(^|\s|\[|-)\@\{$'
    return 1
  endif

  return 0
endfunction

function! s:completer_citations.find_start(start, line) abort dict " {{{2
  let l:start = a:start
  while l:start > 0
    if a:line[:l:start-1] =~# self.start_pattern
      return l:start
    else
      let l:start -=1
    endif
  endwhile
  return -2
endfunction

function! s:completer_citations.complete(base) abort dict " {{{2
  let l:biblatex_file_path =
        \ $HOME .. '/Library/texmf/bibtex/bib/my_library.bib'
  let l:biblatex_file = readfile(l:biblatex_file_path)
  call filter(l:biblatex_file, 'v:val[0] ==# "@"')
  let l:biblatex_keys = map(l:biblatex_file, function('s:biblatex_trim'))
  call filter(l:biblatex_keys, 'v:val =~# "^" .. a:base')
  return l:biblatex_keys
endfunction

function! s:biblatex_trim(index, val) abort " {{{3
  return substitute(a:val, '\v^\@.+\{(.+),$', '\1', '')
endfunction
" }}}3
" }}}2

" Default completer {{{1

let s:completer_default = {}

function! s:completer_default.in_context(line) abort
  return 1
endfunction

function! s:completer_default.find_start(start, line) abort
  return function(b:default_omnifunc)(1, '')
endfunction

function! s:completer_default.complete(base) abort
  return function(b:default_omnifunc)(0, a:base)
endfunction

" }}}1

let s:completers = [
      \ s:completer_citations,
      \ s:completer_default,
      \ ]

function! s:in_yaml_block() abort " {{{1
  let l:start = search('\v^---\s*$', 'bnW')
  if !l:start | return 0 | endif

  let l:end = search('\v^(---|\.\.\.)\s*$', 'nW')
  if !l:end | return 0 | endif

  if getline(l:start + 1) =~# '\v^\s*$' ||
        \ (l:start != 1 && getline(l:start - 1) !~# '\v^\s*$')
    return 0
  endif

  if line('.') > l:start && line('.') < l:end
    return 1
  else
    return 0
  endif
endfunction
