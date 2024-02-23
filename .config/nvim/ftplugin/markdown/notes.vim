if expand('%:p') !~# '/Users/rhelder/Documents/Notes/.*\.md'
    finish
endif

setlocal completefunc=notes#completefunc

nnoremap <buffer> <LocalLeader>nl
            \ <Cmd>call notes#make_bracketed_list_hyphenated()<CR>

augroup mdnotes
    " Run MdviewConvert and build-index when exiting a note, if it has been
    " modified
    autocmd BufWinLeave <buffer> call notes#exit_note()
    autocmd BufModifiedSet <buffer> ++once let b:modified = 1

    " Set flag so that s:run_build_index can force 'hit enter' prompt before
    " quitting
    autocmd ExitPre <buffer> let b:exiting = 1
augroup END

" rfv configuration {{{1

let g:rfv_action = {
            \ 'ctrl-v': 'vertical split',
            \ 'ctrl-x': 'split',
            \ 'ctrl-o': 'silent !md-open',
            \ 'ctrl-]': function('notes#insert_link'),
            \ }

" mdView configuration " {{{1

let g:mdview = {}
let g:mdview.output = function('notes#mdview_output_file')
let g:mdview.pandoc_args = [
            \ '--defaults=notes',
            \ ]

" }}}1
