function! lipsum#insert(par_range = '1', sent_range = '')
    let l:text = []

    let l:par_range = s:parse_range(a:par_range)
    let l:sent_range = s:parse_range(a:sent_range)

    for l:idx in range(l:par_range[0], l:par_range[1])
        call extend(l:text, s:lipsum[l:idx][l:sent_range[0]:l:sent_range[1]])
    endfor

    execute 'normal! a' ..
                \ join(filter(l:text, '!empty(v:val)'), '. ') ..
                \ ".\<Esc>gqgq"
endfunction

function! s:parse_range(range) abort
    if empty(a:range)
        echomsg a:range
        return [0, -1]
    endif

    let l:range =  map(filter(matchlist(a:range, '\v^(\d+)%(-(\d+))?$')[1:2],
                \   '!empty(v:val)'),
                \ 'v:val - 1')

    if len(l:range) ==# 1
        return repeat(l:range, 2)
    else
        return l:range
    endif
endfunction

let s:lipsum = []

let s:in_par = 0
function! s:parse(line) abort
    if a:line =~# '\\NewLipsumPar'
        let s:in_par = 1
        call add(s:lipsum, '')
        return
    endif

    if s:in_par
        if empty(s:lipsum[-1])
            let s:lipsum[-1] = a:line
        else
            let s:lipsum[-1] ..= ' ' .. substitute(a:line, '}.*', '', '')
        endif

        if a:line =~# '}'
            let s:in_par = 0
            let s:lipsum[-1] = split(s:lipsum[-1], '\.\s*')
        endif
    endif
endfunction

call foreach(readfile('/usr/local/texlive/2024/texmf-dist/' ..
            \   'tex/latex/lipsum/lipsum.ltd.tex'),
            \ {index, value -> s:parse(value)})
