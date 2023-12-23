" to-do
" *  Define key bindings

function! s:_silent(commands) abort " {{{1
    " Prevent external commands from triggering 'hit enter' prompt, while still
    " capturing stderr (technically, this function captures both stdout and
    " stderr, but `pandoc`, with the `--output` option, and `open` do not write
    " anything to stdout))

    silent let b:stderr = system(a:commands)
    " Remove null character
    let b:stderr = substitute(b:stderr, '\%x00', '', 'g')

    if v:shell_error > 0
        echoerr b:stderr
    else
        redraw!
    endif
endfunction

function! s:_print_message(message) abort " {{{1
    " Print 'completed' and 'stopped' messages after the style of VimTeX's
    " 'compilation completed' and 'compilation stopped' messages

    highlight MdViewMessage cterm=bold
    echohl Type
    echo 'mdView: '
    echohl MdViewMessage
    echon a:message
    echohl None
    highlight clear MdViewMessage
endfunction

" {{{1 Define filename variables

let s:input = expand("%")
let s:output = substitute(s:input, '_', ' ', 'g')
if matchstr(s:output, '^ ')
    let s:output = substitute(s:output, '^ ', '@')
endif
let s:output = substitute(s:output, '.md$', '.html', '')

function! s:convert() abort " {{{1
    call s:_silent([
                \ 'pandoc',
                \ '--defaults=notes',
                \ '--output',
                \ expand(s:output),
                \ expand(s:input)
                \ ])

    if v:shell_error == 0
        call s:_print_message('Completed')
    endif
endfunction

function! s:open() abort " {{{1
    call s:_silent([
                \ 'open',
                \ '-g',
                \ expand(s:output)
                \ ])
endfunction

function! s:_convert_and_open() abort " {{{1
    call s:convert()
    call s:open()
endfunction

function! s:md_view() abort " {{{1
    if !exists('b:viewed') || b:viewed == 0
        call s:_convert_and_open()
        augroup md_view_convert_and_open
            autocmd!
            autocmd BufWritePost <buffer> call s:_convert_and_open()
        augroup END
        let b:viewed = 1

    elseif b:viewed == 1
        augroup md_view_convert_and_open
            autocmd!
        augroup END
        call s:_print_message('Stopped')
        let b:viewed = 0
    endif
endfunction

" {{{1 Define user commands

command! -buffer Mdview call s:md_view()
command! -buffer MdviewConvert call s:convert()
command! -buffer MdviewOpen call s:open()

" }}}1
