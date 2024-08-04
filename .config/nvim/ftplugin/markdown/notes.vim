if expand('%:p:h') !=# '/Users/rhelder/Documents/Notes'
    finish
endif

setlocal completefunc=notes#completefunc
call notes#init()

augroup notes " {{{1
    autocmd BufModifiedSet <buffer>
                \ call setbufvar(expand('<afile>'), 'modified', 1)
    autocmd User MdviewConvertSuccess
                \ call setbufvar(expand('<abuf>'), 'modified', 0)
    autocmd BufWinLeave <buffer> call notes#exit_note()
augroup END

" Mappings {{{1

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
nnoremap <buffer> <LocalLeader>nh
            \ <Cmd>call notes#make_bracketed_list_hyphenated()<CR>
nnoremap <buffer> <LocalLeader>nl
            \ <Cmd>call fzf#run(fzf#wrap(notes#browse_links(0), 0))<CR>

" mdView configuration {{{1

let g:mdview_pandoc_args = {
            \ 'output': function('notes#mdview_output_file'),
            \ 'additional': ['--defaults=notes'],
            \ }

" ncm2 configuration " {{{1

let s:notes_ncm_word_pattern = '\w+[\w\s.-]*'
let s:notes_ncm_regexes = [
            \ '^\s*-\s+\w*',
            \ '^\s*keywords\s*:\s+(\[\s*)?(\\@)?\w*',
            \ '^\s*keywords\s*:\s+(\[\s*)?(\\@)?(' ..
            \     s:notes_ncm_word_pattern .. ',\s+)+\w*',
            \ '@\w*',
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
