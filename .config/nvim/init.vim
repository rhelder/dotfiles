" Options {{{1

highlight Normal guifg=NvimLightGrey2 guibg=Black
let g:python3_host_prog = '/usr/local/bin/python3'
set belloff=
set completeopt=noinsert,menuone,noselect " As required for ncm2
set cursorline
set cursorlineopt=line
set expandtab
set foldlevelstart=0
set foldmethod=marker
set guicursor=
set ignorecase
set list
set mouse=
set noruler
set number
set report=0
set scrolloff=3
set shiftwidth=4
set smartcase
set smartindent
set softtabstop=4
set spelllang=en_us
set splitbelow
set splitright
set textwidth=79

" Undo files
set undofile
set undodir=$HOME/.cache/vim/undo
if !isdirectory(&undodir)
  call mkdir(&undodir, 'p')
endif

" If 'init.vim' is sourced after startup, the above global settings may
" override local filetype-specific settings. Restore local settings.
if !empty(&filetype)
    execute 'setfiletype ' .. &filetype
endif

" Mappings {{{1

" Set space as leader key
nnoremap <Space> <NOP>
let mapleader = "\<Space>"
let maplocalleader = "\<Space>"

" Source .zshrc mappings and shell variables
source $XDG_CONFIG_HOME/nvim/zshrc.vim

" Source files
nnoremap <Leader>sv <Cmd>source $MYVIMRC<CR>
nnoremap <Leader>sf <Cmd>source %<CR>

" Open terminal in vertical split
nnoremap <Leader>t <Cmd>vsplit<CR><Cmd>terminal<CR>

" Sort case-insensitively
vnoremap <silent> <Leader>si :sort i<CR>

" Move line up or down
nnoremap - ddkP
nnoremap _ ddp

" Help
nnoremap \          <Cmd>vert help<CR>:help 
nnoremap <Leader>h  :help 

" Display
nnoremap <expr> <Esc> v:hlsearch ? "<Cmd>noh<CR>" : "<Esc>"
nnoremap <expr> <Leader>w
            \ &colorcolumn ==# ''
            \     ? "<Cmd>setlocal colorcolumn=+1<CR>"
            \     : "<Cmd>setlocal colorcolumn=<CR>"

" Spell
nnoremap <Leader>sl         :setlocal spelllang=
nnoremap <Leader>sp         <Cmd>setlocal spell!<CR>
nnoremap <expr> <Leader>sn  &spell ? "]sz=" : "<Leader>sn"
nnoremap <expr> <Leader>sN  &spell ? "[sz=" : "<Leader>sN"

" Pattern matching
nnoremap <Leader>pm <Cmd>echo <SID>pattern_matches()<CR>

function! s:pattern_matches() abort " {{{2
    let l:expr = input("Expression:\n")
    redraw
    let l:regex = input("Regular expression:\n")
    redraw
    execute 'let l:result = eval(' .. l:expr .. ' =~# ' .. l:regex .. ')'
    return l:result
endfunction
" }}}2

" Autocommands {{{1

augroup nvimrc " {{{2
    autocmd!

    " When opening a (new) file in ~/.local/bin or in
    " ~/.local/share/zsh/functions, set the filetype to zsh
    autocmd BufReadPost,BufNewFile $HOME/.local/bin/* set filetype=zsh
    autocmd BufReadPost,BufNewFile $XDG_DATA_HOME/zsh/functions/*
                \ set filetype=zsh

    " Run a script converting .zshrc aliases and shell variables into Vim
    " mappings and variables when exiting .zshrc
    autocmd BufWinLeave $XDG_CONFIG_HOME/zsh/.zshrc !sync-vz

    " Convert word lists to .spl files whenever entering a new buffer
    autocmd BufEnter * silent call s:make_spell_files()

    " Enter terminal mode and turn off line numbering when opening terminal
    autocmd TermOpen * startinsert
    autocmd TermOpen * set nonumber
augroup END

augroup nvim_swapfile
    autocmd!
augroup END

function! s:make_spell_files() abort " {{{3
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
" }}}3

augroup nvimrc_filetype_defaults " {{{2
    autocmd!
    autocmd FileType markdown           setlocal formatoptions-=l
    autocmd FileType text,markdown      setlocal textwidth=78
    autocmd FileType text,markdown      setlocal nonumber nosmartindent
    autocmd FileType gitcommit          setlocal nosmartindent textwidth=72
    autocmd BufNewFile *.ly             call append(0, '\version "2.24.3"')
augroup END

augroup nvimrc_key_mappings " {{{2
    autocmd!

    " Comment out lines according to filetype
    autocmd FileType vim
                \ nnoremap <buffer> <LocalLeader>c
                \   <Cmd>call <SID>comment('"', 'n')<CR>
    autocmd FileType vim
                \ vnoremap <buffer> <LocalLeader>c
                \   <Cmd>call <SID>comment('"', 'v')<CR>
    autocmd FileType zsh,conf
                \ nnoremap <buffer> <LocalLeader>c
                \   <Cmd>call <SID>comment('#', 'n')<CR>
    autocmd FileType zsh,conf
                \ vnoremap <buffer> <LocalLeader>c
                \   <Cmd>call <SID>comment('#', 'v')<CR>
    autocmd FileType gpg,lilypond,tex
                \ nnoremap <buffer> <LocalLeader>c
                \   <Cmd>call <SID>comment('%', 'n')<CR>
    autocmd FileType gpg,lilypond,tex
                \ vnoremap <buffer> <LocalLeader>c
                \   <Cmd>call <SID>comment('%', 'v')<CR>

    " Make it easier to exit the command window (from @lervag's vimrc)
    autocmd CmdwinEnter * nnoremap <buffer> q     <C-C><C-C>
    autocmd CmdwinEnter * nnoremap <buffer> <C-F> <C-C>

    " Exit terminal mode when using <C-W> commands to move cursor to another
    " window or to close window
    autocmd TermEnter * tnoremap <buffer> <C-W><C-W> <C-\><C-N><C-W><C-W>
    autocmd TermEnter * tnoremap <buffer> <C-W>w     <C-\><C-N><C-W>w
    autocmd TermEnter * tnoremap <buffer> <C-W>j     <C-\><C-N><C-W>j
    autocmd TermEnter * tnoremap <buffer> <C-W>k     <C-\><C-N><C-W>k
    autocmd TermEnter * tnoremap <buffer> <C-W>h     <C-\><C-N><C-W>h
    autocmd TermEnter * tnoremap <buffer> <C-W>l     <C-\><C-N><C-W>l
    autocmd TermEnter * tnoremap <buffer> <C-W>c     <C-\><C-N>
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

" Plugins {{{1

call plug#begin()
    Plug '/opt/homebrew/opt/fzf'
    Plug '/opt/homebrew/Cellar/lilypond/2.24.3/share/lilypond/2.24.3/vim'
    Plug 'ncm2/ncm2'
    Plug 'roxma/nvim-yarp'
    Plug 'wellle/targets.vim'
    Plug 'jamessan/vim-gnupg'
    Plug 'fladson/vim-kitty'
    Plug 'junegunn/vim-plug'
    Plug 'machakann/vim-sandwich'
    Plug 'lervag/vimtex'
call plug#end()

" Use vim-surround key mappings for vim-sandwich
runtime macros/sandwich/keymap/surround.vim

let g:GPGExecutable = 'PINENTRY_USER_DATA="" gpg --trust-model=always'

" }}}1
