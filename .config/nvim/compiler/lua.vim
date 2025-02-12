if exists('current_compiler') | finish | endif
let current_compiler = 'lua'

command! -buffer Lua
      \ call jobs#jobstart([
      \   'pandoc', 'lua',
      \   expand('%'),
      \ ], {
      \   'name': 'Lua',
      \   'scratch_buf': {'title': 'Lua'},
      \   'on_stdout':
      \     function('jobs#call_callbacks', [['scratch_on_output']]),
      \   'on_stderr':
      \     function('jobs#call_callbacks', [['scratch_on_output']]),
      \   'on_exit':
      \     function('jobs#call_callbacks', [[
      \       'scratch_on_exit',
      \       'notify_on_exit',
      \     ]]),
      \ })
