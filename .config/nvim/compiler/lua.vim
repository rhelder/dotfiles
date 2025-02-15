if exists('current_compiler') | finish | endif
let current_compiler = 'lua'

CompilerSet errorformat=%f:%l\ %m

command! -buffer Lua
      \ call jobs#jobstart([
      \   'pandoc', 'lua',
      \   expand('%'),
      \ ], {
      \   'name': 'Lua',
      \   'scratch_buf': {'title': 'Lua'},
      \   'qflist': {'title': 'Lua'},
      \   'on_stdout': function('jobs#call', ['scratch_on_output']),
      \   'on_stderr': function('jobs#call', ['on_output']),
      \   'on_exit':
      \     function('jobs#call', [['quickfix_on_exit', 'notify_on_exit']]),
      \ })
