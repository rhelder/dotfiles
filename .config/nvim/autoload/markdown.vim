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

function! markdown#omnifunc(findstart, base, completers=[]) abort " {{{1
  if empty(a:completers)
    call extend(a:completers, s:omnifunc_completers)
  endif

  if a:findstart
    if exists('s:completer') | unlet s:completer | endif

    " Subtract by one to align with index of l:line
    let l:start = col('.') - 1
    " Set l:line equal to the portion of the line behind the cursor
    let l:line = getline('.')[:l:start-1]

    for completer in a:completers
      if completer.in_context()
        if has_key(completer, 'find_start')
          let s:completer = completer
          return s:completer.find_start()
        endif

        for pattern in completer.patterns
          if l:line =~# pattern.detect
            let s:completer = completer
            while l:start > 0
              if l:line[:l:start-1] =~# pattern.terminate
                return l:start
              else
                let l:start -=1
              endif
            endwhile
          endif
        endfor
      endif
    endfor
    return -3
  elseif !exists('s:completer')
    " Ordinarily, if s:completer is not defined, completion is cancelled,
    " the function is not called again with findstart=0, and so
    " s:completer.complete is not called; so there's no error that
    " s:completer is undefined. But a wrapper function (such as when you're
    " using an autocomplete plugin) might call the function with
    " findstart=0 regardless. To avoid an error, return an empty list if
    " s:completer is undefined.
    return []
  else
    return s:completer.complete(a:base)
  endif
endfunction

" Citation completer {{{1

let s:completer_citations = {
      \ 'patterns': [
      \     {'detect': '\v(^|\[|\s)\@[0-9A-Za-z._-]*$',
      \         'terminate': '\v(^|\[|\s)\@$'},
      \ ],
      \ }

function! s:completer_citations.in_context() abort dict " {{{2
  let l:pos = col('.') - 1
  let l:line = getline('.')[:l:pos-1]
  for pattern in self.patterns
    if l:pos > 0 && l:line[:l:pos-1] =~# pattern.detect
      return 1
    endif
  endfor
  return 0
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

function! s:completer_default.in_context() abort
  return 1
endfunction

function! s:completer_default.find_start() abort
  return function(b:default_omnifunc)(1, '')
endfunction

function! s:completer_default.complete(base) abort
  return function(b:default_omnifunc)(0, a:base)
endfunction

let s:omnifunc_completers = [
      \ s:completer_citations,
      \ s:completer_default,
      \ ]

" }}}1
