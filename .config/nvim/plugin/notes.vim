" Mappings {{{1

nnoremap <Leader>nb <Cmd>call fzf#run(fzf#wrap(notes#browse_notes(0), 0))<CR>
nnoremap <Leader>ni <Cmd>call fzf#run(fzf#wrap(notes#browse_index(0), 0))<CR>
nnoremap <Leader>nj <Cmd>call notes#new_journal()<CR>
nnoremap <Leader>nn <Cmd>call notes#new_note()<CR>
nnoremap <Leader>ns <Cmd>call notes#search_notes()<CR>
nnoremap <Leader>nw <Cmd>call notes#index_word_count()<CR>

" rfv configuration {{{1

let g:rfv_action = {
            \ 'ctrl-v': 'vertical split',
            \ 'ctrl-x': 'split',
            \ 'ctrl-o': 'silent !md-open',
            \ 'ctrl-]': function('notes#insert_link'),
            \ }

" }}}1
