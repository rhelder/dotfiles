if exists('current_compiler') | finish | endif
let current_compiler = 'lua'

command! -buffer Lua
      \ call shell#jobstart([
      \   'texlua',
      \   expand('%'),
      \ ], {
      \   'scratch': 3,
      \   'scratch_buf': {
      \     'title': 'lua ' .. expand('%'),
      \     'active': 1,
      \   },
      \ })
