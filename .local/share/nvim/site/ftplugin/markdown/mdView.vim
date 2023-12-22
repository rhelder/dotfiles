" to-do
" *  Define key bindings

" {{{1 s:_silent()

" Prevent external commands from triggering 'hit enter' prompt, while still
" capturing stderr (technically, this function captures both stdout and stderr,
" but `pandoc`, with the `--output` option, and `open` do not write anything to
" stdout))
function! s:_silent(commands) abort
    silent let b:stderr = system(a:commands)
    if v:shell_error > 0
        echoerr b:stderr
    else
        redraw!
    endif
endfunction

command! -buffer -nargs=1 Silent call s:_silent(<f-args>)

" {{{1 s:_print_message

" Print 'completed' and 'stopped' messages after the style of VimTeX's
" 'compilation completed' and 'compilation stopped' messages

highlight MdViewMessage cterm=bold
function! s:_print_message(message) abort
    echohl Type
    echo 'mdView: '
    echohl MdViewMessage
    echon a:message
    echohl None
endfunction

" {{{1 s:convert

function! s:convert() abort
    let l:input = expand("%")
    let l:output = substitute(input, '_', ' ', 'g')
    if matchstr(l:output, '^ ')
        let l:output = substitute(l:output, '^ ', '@')
    endif
    let l:output = substitute(l:output, '.md$', '.html', '')
    let $INPUT_FILE = l:input
    let $OUTPUT_FILE = l:output

    Silent pandoc --defaults=notes --output $OUTPUT_FILE $INPUT_FILE

    if v:shell_error == 0
        call s:_print_message('Completed')
    endif
endfunction

" {{{1 s:md_view

function! s:_convert_and_open() abort
    call s:convert()
    Silent open -g $OUTPUT_FILE
endfunction

" If b:viewed is off, call s:_convert_and_open(), define autocommand that calls
" s:_convert_and_open whenever the buffer is written, and switch `b:viewed` on.
" When `b:viewed` is on, delete the autocommand, print a message that mdView
" has stopped, and switch b:viewed back off.

let b:viewed = 0

function! s:md_view() abort
    if b:viewed == 0
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
command! -buffer MdviewOpen Silent open -g $OUTPUT_FILE

" {{{1 Clean up

augroup md_view_cleanup
    autocmd!
    autocmd BufWinLeave *.md highlight clear MdViewMessage
augroup END

unlet $INPUT_FILE
unlet $OUTPUT_FILE

" }}}1
