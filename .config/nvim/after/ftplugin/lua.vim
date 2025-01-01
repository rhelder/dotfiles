compiler lua

nmap <buffer> <LocalLeader>ll <Plug>(lua-compile)
nmap <buffer> <script> <Plug>(lua-compile) <SID>(lua-compile)
nnoremap <buffer> <SID>(lua-compile) <Cmd>Lua<CR>
