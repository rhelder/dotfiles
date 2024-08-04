function! notes#u#in_keywords() abort " {{{1
    if !notes#u#in_yaml_block() | return 0 | endif

    let l:key_line_number = search(s:yaml_key_regex, 'bnW')
    if !l:key_line_number | return 0 | endif
    let l:key_line = getline(l:key_line_number)
    if matchstr(l:key_line, s:yaml_key_regex) ==# 'keywords'
        return 1
    else
        return 0
    endif
endfunction

function! notes#u#in_yaml_block() abort " {{{1
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

let s:yaml_key_start_chars = '[^\-?:,[\]{}#&*!|>''"%@`[:space:]]'
let s:yaml_key_can_start_if_chars = '[?:\-]([^[:space:]])@='
let s:yaml_key_subsequent_chars = '(\S#|:\S|[^[:space:]:#])*'
let s:yaml_key_chars = '(' .. s:yaml_key_start_chars .. '|' ..
            \ s:yaml_key_can_start_if_chars .. ')' ..
            \ s:yaml_key_subsequent_chars
let s:yaml_key_regex = '\v^\s*\zs' .. s:yaml_key_chars ..
            \ '(\s+' .. s:yaml_key_chars .. ')*\ze\s*:(\s|$)'

" }}}1
