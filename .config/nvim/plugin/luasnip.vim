lua require('luasnip').setup({
      \ enable_autosnippets = true,
      \ store_selection_keys = '<Tab>',
      \ update_events = {'TextChanged', 'TextChangedI'},
      \ snip_env = {
      \   get_visual = require('rhelder.luasnip').get_visual,
      \   },
      \ })

lua require('luasnip.loaders.from_lua').load(
      \ {paths = '~/.config/nvim/luasnippets'})

imap <silent><expr> <Tab> luasnip#expand_or_jumpable()
      \ ? '<Plug>luasnip-expand-or-jump'
      \ : '<Tab>'
smap <silent><expr> <Tab> luasnip#jumpable(1)
      \ ? '<Plug>luasnip-jump-next'
      \ : '<Tab>'

imap <silent><expr> <S-Tab> luasnip#jumpable(-1)
      \ ? '<Plug>luasnip-jump-prev'
      \ : '<S-Tab>'
smap <silent><expr> <S-Tab> luasnip#jumpable(-1)
      \ ? '<Plug>luasnip-jump-prev'
      \ : '<S-Tab>'

imap <silent><expr> <C-J> luasnip#choice_active()
      \ ? '<Plug>luasnip-next-choice'
      \ : '<C-J>'
smap <silent><expr> <C-J> luasnip#choice_active()
      \ ? '<Plug>luasnip-next-choice'
      \ : '<C-J>'
imap <silent><expr> <C-K> luasnip#choice_active()
      \ ? '<Plug>luasnip-prev-choice'
      \ : '<C-K>'
smap <silent><expr> <C-K> luasnip#choice_active()
      \ ? '<Plug>luasnip-prev-choice'
      \ : '<C-K>'

" Don't jump back to a snippet after you've left the snippet {{{2
" The code is mainly from @augustocdias (LuaSnip issue #258), but require that
" we are not changing into an insert-completion mode when we leave insert mode.
" Note: still doesn't work if you haven't jumped all the way through a snippet
" in which another snippet is nested, but still a big improvement.
augroup luasnip_config
  autocmd!
  autocmd ModeChanged * call s:leave_luasnippet()
  " Fix EOF syntax highlighting
  autocmd FileType vim lua vim.treesitter.start()
augroup END

function! s:leave_luasnippet() abort
lua << EOF
  local ls = require('luasnip')
  if (
      (vim.v.event.old_mode == 's' and vim.v.event.new_mode == 'n')
      or (
        vim.v.event.old_mode == 'i'
        and not
        (vim.v.event.new_mode == 'ix' or vim.v.event.new_mode == 'ic')
      )
    )
    and ls.session.current_nodes[vim.api.nvim_get_current_buf()]
    and not ls.session.jump_active
  then
    ls.unlink_current()
  end
EOF
endfunction
" }}}2

" }}}1
