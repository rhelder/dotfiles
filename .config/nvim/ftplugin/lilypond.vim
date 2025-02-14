if exists('b:did_ftplugin') | finish | endif
let b:did_ftplugin = 1

compiler lilypond

nmap <buffer> <LocalLeader>ll <Plug>(lilypond-compile)
nmap <buffer> <script> <Plug>(lilypond-compile) <SID>(lilypond-compile)
nnoremap <buffer> <SID>(lilypond-compile) <Cmd>Lilypond<CR>
