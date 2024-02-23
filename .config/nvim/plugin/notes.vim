nnoremap <Leader>nj <Cmd>call notes#new_journal()<CR>
nnoremap <Leader>nn <Cmd>call notes#new_note()<CR>
nnoremap <Leader>ns <Cmd>call notes#search_notes()<CR>
nnoremap <Leader>ni <Cmd>call fzf#run(fzf#wrap(notes#browse_index()))<CR>
