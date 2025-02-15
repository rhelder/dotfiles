" Options {{{1

" Editing
set expandtab
set nosmarttab
set shiftwidth=2
set softtabstop=2
set textwidth=79

" Search
set ignorecase
set smartcase

" UI
set belloff=
set mouse=

" Display
set cursorline
set cursorlineopt=line
set guicursor=a:block
set list
set noruler
set report=0
set scrolloff=3

" Windows
set diffopt+=vertical
set splitbelow
set splitright

" Folding
set foldlevelstart=0
set foldmethod=marker

" Spell
set spelllang=en_us

" Undo and swap file
set undofile
set undodir=$HOME/.cache/vim/undo
if !isdirectory(&undodir)
  call mkdir(&undodir, 'p')
endif
" Do not skip swapfile prompt (':help default-autocmds')
autocmd! nvim_swapfile

" Filetype-specific options {{{2

" If 'init.vim' is re-sourced, re-set filetype-specific options
if !empty(&filetype) " i.e., only after startup
  doautocmd nvimrc_options FileType
endif

augroup nvimrc_ftdetect
  autocmd!
  autocmd BufReadPost,BufNewFile $HOME/.local/bin/*
        \ execute empty(expand('%:e'))
        \   ? 'set filetype=zsh'
        \   : ''
  autocmd BufReadPost,BufNewFile $XDG_DATA_HOME/zsh/functions/*
        \ set filetype=zsh
  autocmd BufReadPost,BufNewFile *.lvt set filetype=tex
  autocmd BufReadPost,BufNewFile *.4ht set filetype=tex
  autocmd BufReadPost,BufNewFile $HOME/Library/texmf/tex/generic/tex4ht/*
        \ set filetype=tex
augroup END

augroup nvimrc_options
  autocmd Filetype,VimResized * call s:set_number()
  autocmd FileType gitcommit setlocal textwidth=72
  autocmd FileType * setlocal formatoptions+=n
augroup END

function! s:set_number() abort " {{{3
  if &filetype =~# '\v(text|markdown|gitcommit|help|man|qf)'
    return
  endif

  " 82 = default kitty window width + padding
  if &columns <# (82 + len(line('$')))
    setlocal nonumber
  else
    setlocal number
  endif
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

" Edit
nmap <Leader>c gcc
vmap <Leader>c gc
nnoremap - ddkP | " Move line up
nnoremap _ ddp | " Move line down
vnoremap <silent> <Leader>si :sort i<CR>

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

" Source
nnoremap <Leader>sf <Cmd>source %<CR>
nnoremap <Leader>sv <Cmd>source $MYVIMRC<CR>

" Use '<Tab>' to accept the current match and continue completing (not to cycle
" through further possible options)
cnoremap <expr> <Tab> wildmenumode()
      \ ? "\<C-Y>\<C-Z>"
      \ : "\<C-Z>"

augroup nvimrc_mappings
  autocmd!
  " Make it easier to exit the command line window (from @lervag's vimrc)
  autocmd CmdwinEnter * nnoremap <buffer> q     <C-C><C-C>
  autocmd CmdwinEnter * nnoremap <buffer> <C-F> <C-C>
augroup END

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
    if (filereadable(expand(file)) && !filereadable(expand(file) .. '.spl'))
          \ || (getftime(expand(file)) >=# getftime(expand(file) .. '.spl'))
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
  Plug '~/.local/share/nvim/vimtex'
call plug#end()

" Set options required for ncm2
let g:python3_host_prog = '/usr/local/bin/python3'
set completeopt=noinsert,menuone,noselect

" Use vim-surround key mappings for vim-sandwich
runtime macros/sandwich/keymap/surround.vim

" }}}1
