if exists('b:did_ftplugin_notes') | finish | endif
let b:did_ftplugin_notes = 1

if expand('%:p:h') !=# '/Users/rhelder/Documents/Notes'
    finish
endif

" Mappings {{{1

" fzf {{{2
nnoremap <buffer> <LocalLeader>nl
            \ <Cmd>call fzf#run(fzf#wrap(notes#fzf#browse_links(0), 0))<CR>

" Links {{{2
nnoremap <buffer> <CR>
            \ <Cmd>call notes#link#follow_link_map(
            \   'edit', 'markdown', "\<lt>CR>")<CR>
nnoremap <buffer> <C-W><C-V>
            \ <Cmd>call notes#link#follow_link_map(
            \   'vsplit', 'markdown', "\<lt>C-W>\<lt>C-V>")<CR>
nnoremap <buffer> <C-W>v
            \ <Cmd>call notes#link#follow_link_map(
            \   'vsplit', 'markdown', "\<lt>C-W>v")<CR>
nnoremap <buffer> <C-W><C-O>
            \ <Cmd>call notes#link#follow_link_map(
            \   '!open', 'html', "\<lt>C-W>\<lt>C-O>")<CR>
nnoremap <buffer> <C-W>o
            \ <Cmd>call notes#link#follow_link_map(
            \   '!open', 'html', "\<lt>C-W>o")<CR>

" Other {{{2
nnoremap <buffer> <LocalLeader>nh
            \ <Cmd>call notes#make_bracketed_list_hyphenated()<CR>
nnoremap <buffer> <LocalLeader>qq <Cmd>call notes#set_modified(0, 0)<CR>
" }}}2

" Completion {{{1

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

let s:ncm_word_pattern = '\w+[\w\s.-]*'
let s:ncm_regexes = [
            \ '^\s*-\s+\w*',
            \ '^\s*keywords\s*:\s+(\[\s*)?(\\@)?\w*',
            \ '^\s*keywords\s*:\s+(\[\s*)?(\\@)?(' ..
            \     s:ncm_word_pattern .. ',\s+)+\w*',
            \ '@\w*',
            \ ]

augroup notes_exit_note " {{{1
    autocmd BufModifiedSet <buffer>
                \ call setbufvar(expand('<afile>'), 'modified', 1)
    autocmd BufModifiedSet <buffer> call notes#set_modified(1)
    autocmd BufWinLeave <buffer> call notes#exit_note()
augroup END

" mdView {{{1
let g:mdview_pandoc_args = {
            \ 'output': function('notes#mdview_output_file'),
            \ 'additional': ['--defaults=notes'],
            \ }

" }}}1
