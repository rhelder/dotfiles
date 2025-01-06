" Options {{{1

set belloff=
set cursorline
set cursorlineopt=line
set diffopt+=vertical
set expandtab
set foldlevelstart=0
set foldmethod=marker
set guicursor=
set ignorecase
set list
set mouse=
set noruler
set report=0
set scrolloff=3
set shiftwidth=2
set smartcase
set smartindent
set softtabstop=2
set spelllang=en_us
set splitbelow
set splitright
set textwidth=79

" Use undo files
set undofile
set undodir=$HOME/.cache/vim/undo
if !isdirectory(&undodir)
  call mkdir(&undodir, 'p')
endif

" Do not skip swapfile prompt (':help default-autocmds')
autocmd! nvim_swapfile

" If 'init.vim' is re-sourced after startup, global settings may override local
" filetype-specific settings. Restore local settings.
if !empty(&filetype) " i.e., only after startup
  doautocmd nvimrc_options FileType
endif

augroup nvimrc_options " {{{2
  autocmd!
  autocmd VimEnter,VimResized * call s:set_number()
  autocmd FileType text,markdown,gitcommit,help,man setlocal nonumber

  autocmd BufReadPost,BufNewFile $HOME/.local/bin/*
        \ set filetype=zsh
  autocmd BufReadPost,BufNewFile $XDG_DATA_HOME/zsh/functions/*
        \ set filetype=zsh
  autocmd BufReadPost,BufNewFile $HOME/Library/texmf/tex/generic/tex4ht/*
        \ set filetype=tex
  autocmd BufReadPost,BufNewFile *.4ht set filetype=tex
  autocmd BufReadPost,BufNewFile *.lvt set filetype=tex

  autocmd FileType markdown setlocal formatoptions-=l
  autocmd FileType text,markdown setlocal textwidth=78
  autocmd FileType gitcommit setlocal textwidth=72
  autocmd FileType text,markdown,gitcommit setlocal nosmartindent
  autocmd FileType markdown,gitcommit setlocal shiftwidth=4
  autocmd FileType markdown,gitcommit setlocal softtabstop=4
  autocmd FileType help setlocal nolist
augroup END

function! s:set_number() abort " {{{3
  " 82 = default kitty window width + padding
  if &columns <# (82 + len(line('$')))
    set nonumber
  else
    set number
  endif

  doautocmd nvimrc_options FileType
endfunction
" }}}3
" }}}2

" Mappings {{{1

nnoremap <Space> <NOP>
let mapleader = "\<Space>"
let maplocalleader = "\<Space>"

" Source mappings corresponding to '.zshrc' aliases (and global variables
" corresponding to '.zshrc' shell variables)
source $XDG_CONFIG_HOME/nvim/zshrc.vim
" Make 'zshrc.vim' when exiting '.zshrc'
augroup nvimrc_zshrc
  autocmd!
  autocmd BufWinLeave $XDG_CONFIG_HOME/zsh/.zshrc !zshrc2vimrc
augroup END

" Source
nnoremap <Leader>sf <Cmd>source %<CR>
nnoremap <Leader>sv <Cmd>source $MYVIMRC<CR>
" Help
nnoremap \          <Cmd>vert help<CR>:help 
nnoremap <Leader>h  :help 
" Display
nnoremap <expr> <Esc> v:hlsearch
      \ ? "<Cmd>noh<CR>"
      \ : "<Esc>"
nnoremap <expr> <Leader>w
      \ &colorcolumn ==# ''
      \   ? "<Cmd>setlocal colorcolumn=+1<CR>"
      \   : "<Cmd>setlocal colorcolumn=<CR>"
" Edit
nnoremap -  ddkP | " Move line up
nnoremap _  ddp | " Move line down
vnoremap <silent> <Leader>si :sort i<CR>
" Use '<Tab>' to accept the current match and continue completing (not to cycle
" through further possible options)
cnoremap <expr> <Tab> wildmenumode()
      \ ? "\<C-Y>\<C-Z>"
      \ : "\<C-Z>"

augroup nvimrc_mappings " {{{2
  autocmd!
  autocmd FileType vim
        \ nnoremap <buffer> <LocalLeader>c
        \   <Cmd>call <SID>comment('"', 'n')<CR>
  autocmd FileType vim
        \ vnoremap <buffer> <LocalLeader>c
        \   <Cmd>call <SID>comment('"', 'v')<CR>
  autocmd FileType lua
        \ nnoremap <buffer> <LocalLeader>c
        \   <Cmd>call <SID>comment('--', 'n')<CR>
  autocmd FileType lua
        \ vnoremap <buffer> <LocalLeader>c
        \   <Cmd>call <SID>comment('--', 'v')<CR>
  autocmd FileType zsh,conf,toml
        \ nnoremap <buffer> <LocalLeader>c
        \   <Cmd>call <SID>comment('#', 'n')<CR>
  autocmd FileType zsh,conf,toml
        \ vnoremap <buffer> <LocalLeader>c
        \   <Cmd>call <SID>comment('#', 'v')<CR>
  autocmd FileType gpg,lilypond,tex
        \ nnoremap <buffer> <LocalLeader>c
        \   <Cmd>call <SID>comment('%', 'n')<CR>
  autocmd FileType gpg,lilypond,tex
        \ vnoremap <buffer> <LocalLeader>c
        \   <Cmd>call <SID>comment('%', 'v')<CR>

  " Make it easier to exit the command line window (from @lervag's vimrc)
  autocmd CmdwinEnter * nnoremap <buffer> q     <C-C><C-C>
  autocmd CmdwinEnter * nnoremap <buffer> <C-F> <C-C>
augroup END

function! s:comment(character, mode) abort " {{{3
  let l:range = []
  call add(l:range, line('.'))
  if a:mode ==# 'v'
    call add(l:range, line('v'))
    call sort(l:range, 'n')
    let l:range = range(l:range[0], l:range[1])
  endif

  for l:lnum in l:range
    let l:line = getline(l:lnum)
    let l:pattern = '\v^(\s*)\' .. a:character
    if match(l:line, l:pattern) ==# -1
      if !empty(line)
        call setline(l:lnum, substitute(l:line, '\v^(\s*)(\S|$)',
              \ '\1' .. a:character .. ' \2', ''))
      else
        call setline(l:lnum, a:character)
      endif
    else
      call setline(l:lnum, substitute(l:line, l:pattern .. '\s*',
            \ '\1', ''))
    endif
  endfor

  if a:mode ==# 'v' | execute "normal! \<Esc>" | endif
endfunction
" }}}3
" }}}2

" Spell {{{1

nnoremap <Leader>sl :setlocal spelllang=
nnoremap <Leader>sp <Cmd>setlocal spell!<CR>
nnoremap <expr> <Leader>sn &spell
      \ ? "]sz="
      \ : "<Leader>sn"
nnoremap <expr> <Leader>sN &spell
      \ ? "[sz="
      \ : "<Leader>sN"

augroup nvimrc_spell
  autocmd!
  autocmd BufEnter * silent call s:make_spell_files()
augroup END

function! s:make_spell_files() abort " {{{2
  for file in glob('$XDG_CONFIG_HOME/nvim/spell/*.add', 0, 1)
    if (filereadable(expand(file)) &&
          \ !filereadable(expand(file) .. '.spl'))
          \ ||
          \ (getftime(expand(file)) >=
          \ getftime(expand(file) .. '.spl'))
      execute 'mkspell! ' .. file
    endif
  endfor
endfunction
" }}}2

" Plugins {{{1

call plug#begin()
  Plug 'mattn/emmet-vim', {'for': ['html', 'xml']}
  Plug '/opt/homebrew/opt/fzf'
  Plug '/opt/homebrew/Cellar/lilypond/2.24.3/share/lilypond/2.24.3/vim'
  Plug 'L3MON4D3/LuaSnip', {'tag': 'v2.*', 'do': 'make install_jsregexp'}
  Plug 'ncm2/ncm2'
  Plug 'roxma/nvim-yarp'
  Plug 'wellle/targets.vim'
  Plug 'jamessan/vim-gnupg'
  Plug 'fladson/vim-kitty'
  Plug 'junegunn/vim-plug'
  Plug 'machakann/vim-sandwich'
  Plug 'lervag/vimtex'
call plug#end()

" Set options required for ncm2
let g:python3_host_prog = '/usr/local/bin/python3'
set completeopt=noinsert,menuone,noselect

" Use vim-surround key mappings for vim-sandwich
runtime macros/sandwich/keymap/surround.vim

let g:mdview_pandoc_args = {
      \ 'additional': ['--defaults=github'],
      \ }

let g:GPGExecutable = 'PINENTRY_USER_DATA="" gpg --trust-model=always'

" LuaSnip configuration {{{2

lua require('luasnip.loaders.from_lua').load(
      \ {paths = '~/.config/nvim/luasnippets'})

lua require('luasnip').setup({
      \ enable_autosnippets = true,
      \ store_selection_keys = '<Tab>',
      \ })

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
" }}}2

" }}}1
