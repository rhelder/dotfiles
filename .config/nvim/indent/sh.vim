function! s:line_continuation_indent() abort
    return 2 * shiftwidth()
endfunction

let b:sh_indent_options = {
            \ 'continuation-line': function('s:line_continuation_indent'),
            \ }
