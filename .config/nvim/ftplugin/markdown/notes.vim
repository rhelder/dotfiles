if !get(b:, 'notes_enabled', 0) | finish | endif

setlocal completefunc=notes#completefunc

nnoremap <buffer> <CR>
            \ <Cmd>call notes#follow_link_map(
            \   'edit', 'markdown', "\<lt>CR>")<CR>
nnoremap <buffer> <C-W><C-V>
            \ <Cmd>call notes#follow_link_map(
            \   'vsplit', 'markdown', "\<lt>C-W>\<lt>C-V>")<CR>
nnoremap <buffer> <C-W>v
            \ <Cmd>call notes#follow_link_map(
            \   'vsplit', 'markdown', "\<lt>C-W>v")<CR>
nnoremap <buffer> <C-W><C-O>
            \ <Cmd>call notes#follow_link_map(
            \   '!open', 'html', "\<lt>C-W>\<lt>C-O>")<CR>
nnoremap <buffer> <C-W>o
            \ <Cmd>call notes#follow_link_map(
            \   '!open', 'html', "\<lt>C-W>o")<CR>
nnoremap <buffer> <LocalLeader>nl
            \ <Cmd>call notes#make_bracketed_list_hyphenated()<CR>

augroup notes
    " Run MdviewConvert and build-index when exiting a note, if it has been
    " modified
    autocmd BufWinLeave <buffer> call notes#exit_note()
    autocmd BufModifiedSet <buffer> ++once
                \ call setbufvar(expand('<afile>'), 'modified', 1)

    " Set flag so that s:run_build_index can force 'hit enter' prompt before
    " quitting
    autocmd ExitPre <buffer> call setbufvar(expand('<afile>'), 'exiting', 1)
augroup END

" mdView configuration {{{1

let b:mdview = {}
let b:mdview.output = function('notes#mdview_output_file')
let b:mdview.pandoc_args = [
            \ '--defaults=notes',
            \ ]

" ncm2 configuration " {{{1

let s:notes_ncm_word_pattern = '\w+[\w\s.-]*'
let s:notes_ncm_regexes = [
            \ '^\s*-\s+\w+',
            \ '^\s*keywords\s*:\s+(\[\s*)?(\\@)?\w+',
            \ '^\s*keywords\s*:\s+(\[\s*)?(\\@)?(' ..
            \     s:notes_ncm_word_pattern .. ',\s+)+\w+',
            \ '@\w+',
            \ ]

augroup ncm_notes
    autocmd!
    autocmd BufEnter $HOME/Documents/Notes/*.md call ncm2#enable_for_buffer()
    autocmd User Ncm2Plugin call ncm2#register_source({
                \ 'name': 'notes',
                \ 'priority': 8,
                \ 'scope': ['markdown'],
                \ 'matcher': {'name': 'prefix', 'key': 'word'},
                \ 'sorter': 'none',
                \ 'word_pattern': s:notes_ncm_word_pattern,
                \ 'complete_pattern': s:notes_ncm_regexes,
                \ 'on_complete': ['ncm2#on_complete#omni',
                \     'notes#completefunc'],
                \ })
augroup END

" }}}1
