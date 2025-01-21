if exists('b:did_ftplugin_notes') | finish | endif
let b:did_ftplugin_notes = 1

if expand('%:p:h') !=# '/Users/rhelder/Documents/Notes'
    finish
endif

" Mappings {{{1

" Exit " {{{2
nnoremap <buffer> <LocalLeader>qq <Cmd>call notes#exit#set_modified(0, 0)<CR>

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
" }}}2

augroup notes_exit " {{{1
    autocmd BufModifiedSet <buffer>
                \ call setbufvar(expand('<afile>'), 'modified', 1)
    autocmd BufModifiedSet <buffer> call notes#exit#set_modified(1)
    autocmd BufWinLeave <buffer> call notes#exit#compile()
augroup END

" mdView {{{1
let g:mdview_pandoc_args = {
            \ 'output': function('notes#mdview#output_file'),
            \ 'additional': ['--defaults=notes'],
            \ }

" }}}1
