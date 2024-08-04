function! notes#complete#init_buffer() abort " {{{1
    setlocal completefunc=notes#complete#completefunc

    augroup ncm2_notes
        autocmd!
        autocmd BufEnter * call ncm2#enable_for_buffer()
        autocmd User Ncm2Plugin call ncm2#register_source({
                    \ 'name': 'notes',
                    \ 'priority': 8,
                    \ 'scope': ['markdown'],
                    \ 'matcher': {'name': 'prefix', 'key': 'word'},
                    \ 'sorter': 'none',
                    \ 'word_pattern': s:ncm_word_pattern,
                    \ 'complete_pattern': s:ncm_regexes,
                    \ 'on_complete': ['ncm2#on_complete#omni',
                    \     'notes#complete#completefunc'],
                    \ })
    augroup END
endfunction

let s:ncm_word_pattern = '\w+[\w\s.-]*'
let s:ncm_regexes = [
            \ '^\s*-\s+\w*',
            \ '^\s*keywords\s*:\s+(\[\s*)?(\\@)?\w*',
            \ '^\s*keywords\s*:\s+(\[\s*)?(\\@)?(' ..
            \     s:ncm_word_pattern .. ',\s+)+\w*',
            \ '@\w*',
            \ ]

" }}}1

function! notes#complete#omnifunc(findstart, base, completers=[]) abort " {{{1
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

function! notes#complete#completefunc(findstart, base) abort " {{{1
    return notes#complete#omnifunc(a:findstart, a:base,
                \ s:completefunc_completers)
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

" Keyword completer {{{1

let s:completer_keywords = {
            \ 'patterns': [
            \     {'detect': '\v^\s*keywords\s*:\s+\[=([^,]*,\s+)*',
            \         'terminate': '\v^\s*keywords:\s+\[=([^,]*,\s+)*$'},
            \     {'detect': '\v^\s*-\s+', 'terminate': '\v^\s*-\s+$'},
            \ ],
            \ }

function! s:completer_keywords.in_context() abort dict " {{{2
    return notes#u#in_keywords()
endfunction

function! s:completer_keywords.complete(base) abort dict " {{{2
    if a:base[0:1] == '\@'
        let l:biblatex_keys = s:completer_citations.complete(a:base[2:])
        call map(l:biblatex_keys, '{"word": "\\@" .. v:val, "abbr": v:val}')
        return l:biblatex_keys

    else
        let l:name = $HOME .. '/Documents/Notes/index.txt'
        let l:keywords = readfile(l:name)
        call filter(l:keywords, 'v:val !~# "^@"')
        call filter(l:keywords, 'v:val =~? "^" .. a:base')
        return l:keywords
    endif
endfunction
" }}}2

" }}}1

let s:omnifunc_completers = [
            \ s:completer_citations,
            \ s:completer_default,
            \ ]

let s:completefunc_completers = [
            \ s:completer_keywords,
            \ s:completer_citations,
            \ ]
