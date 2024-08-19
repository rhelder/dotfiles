if exists('g:loaded_notes') | finish | endif
let g:loaded_notes = 1

nnoremap <Leader>nn <Cmd>call notes#new_note()<CR>
nnoremap <Leader>nj <Cmd>call notes#new_journal()<CR>

nnoremap <Leader>ns <Cmd>call notes#fzf#search_notes()<CR>
nnoremap <Leader>nb
            \ <Cmd>call fzf#run(fzf#wrap(notes#fzf#browse_notes(0), 0))<CR>
nnoremap <Leader>ni
            \ <Cmd>call fzf#run(fzf#wrap(notes#fzf#browse_index(0), 0))<CR>
