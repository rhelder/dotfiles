" {{{1 Options

let &formatlistpat = '^\s*\(\d\|\*\|+\|-\)\+[\]:.)}\t ]\s*'
let &spellfile =
	\ '~/.config/nvim/spell/en.utf-8.add,
	\~/.config/nvim/spell/de.utf-8.add'
let g:python3_host_prog = '/usr/local/bin/python3'
let g:vim_indent_cont = shiftwidth() * 1
set belloff=
set cursorline
set cursorlineopt=line
set foldlevelstart=0
set foldmethod=marker
set formatoptions+=n
set gdefault
set guicursor=
set ignorecase
set mouse=
set noruler
set number
set report=0
set scrolloff=3
set shiftwidth=5
set smartcase
set smartindent
set softtabstop=5
set spelllang=en_us
set splitbelow
set splitright
set textwidth=78

" {{{1 Variables

let arist = '~/Library/texmf/tex/latex/aristotelis/aristotelis.sty'
let db = '~/Library/CloudStorage/Dropbox'
let nvimrc = '~/.config/nvim/init.vim'
let rhelder = '~/Library/texmf/tex/latex/rhelder/rhelder.sty'
let texmf = '~/Library/texmf'
let ucb = '~/Library/CloudStorage/Dropbox/UCBerkeley'
let vtc = '~/.local/share/nvim/site/vimtex/autoload/vimtex/complete'
let zshrc = '~/.zshrc'

" {{{1 Mappings

" Use `<Space>` as leader key
nnoremap <Space> <NOP>
let mapleader = "\<Space>"
let maplocalleader = "\<Space>"

" Open/load files
nnoremap <Leader>ea <Cmd>execute 'vsplit ' .. arist<CR>
nnoremap <Leader>es <Cmd>execute 'vsplit ' .. rhelder<CR>
nnoremap <Leader>ev <Cmd>vsplit $MYVIMRC<CR>
nnoremap <Leader>ez <Cmd>execute 'vsplit ' .. zshrc<CR>
nnoremap <Leader>sv <Cmd>source $MYVIMRC<CR>

" Open help
nnoremap <Leader>hv <Cmd>vert help<CR>:help 
nnoremap <Leader>hs <Cmd>help<CR>:help 

" Open terminal
nnoremap <Leader>t <Cmd>terminal<CR>
nnoremap <Leader>T <Cmd>vsplit<CR><Cmd>terminal<CR>

" Switch off search highlighting
nnoremap <silent> <Leader><Esc> <Cmd>noh<CR>

" Spell check
nnoremap <Leader>sl :set spelllang=<C-R>=&spelllang<CR>
nnoremap <Leader>sp <Cmd>set spell!<CR>

" Navigation
nnoremap H ^
nnoremap L $

" Move lines up or down
nnoremap - ddkP
nnoremap _ ddp

" Uppercase word
nnoremap <Leader>u viwUe

" Surround word or selection with delimiters
nnoremap <Leader>{ ea}<Esc>bi{<Esc>el
vnoremap <Leader>{ <Esc>`<i{<Esc>`>a}<Esc>

" {{{1 Autocommands

augroup nvimrc_filetype_defaults
     autocmd!
     autocmd FileType markdown setlocal formatoptions-=l
     autocmd FileType csv setlocal formatoptions-=tc
     autocmd FileType tex setlocal formatoptions-=tc
     autocmd FileType tex setlocal formatoptions+=l
     autocmd FileType text,markdown,tex setlocal linebreak
     autocmd BufWinEnter COMMIT_EDITMSG setlocal textwidth=72
     autocmd FileType tex setlocal nosmartindent
     autocmd FileType markdown source ~/mdView/mdView.vim
augroup END

augroup nvrimc_key_mappings
     autocmd!

     " Comment out lines according to filetype
     autocmd FileType vim nnoremap <buffer> <LocalLeader>c I"<Space><Esc>
     autocmd FileType zsh nnoremap <buffer> <LocalLeader>c I#<Space><Esc>
     autocmd FileType tex nnoremap <buffer> <LocalLeader>c I%<Space><Esc>

     " Make it easier to exit the command window (from @lervag's `vimrc`)
     autocmd CmdwinEnter * nnoremap <buffer> q <C-C><C-C>
     autocmd CmdwinEnter * nnoremap <buffer> <C-F> <C-C>

     " Exit terminal mode when using `<C-W>` commands to move cursor to another
     " window or to close window
     autocmd TermEnter * tnoremap <buffer> <C-W><C-W> <C-\><C-N><C-W><C-W>
     autocmd TermEnter * tnoremap <buffer> <C-W>w <C-\><C-N><C-W>w
     autocmd TermEnter * tnoremap <buffer> <C-W>j <C-\><C-N><C-W>j
     autocmd TermEnter * tnoremap <buffer> <C-W>k <C-\><C-N><C-W>k
     autocmd TermEnter * tnoremap <buffer> <C-W>h <C-\><C-N><C-W>h
     autocmd TermEnter * tnoremap <buffer> <C-W>l <C-\><C-N><C-W>l
     autocmd TermEnter * tnoremap <buffer> <C-W>c <C-\><C-N>
augroup END

augroup nvimrc_autocommands
     autocmd!
     " Enter terminal mode when opening terminal
     autocmd TermOpen * startinsert
augroup END

" Rebuild `.spl` files upon initialization, and then subsequently whenever a
" buffer is loaded (or a hidden buffer is displayed) in a new window
function Mkspell()
     let l:spellfiles = split(&spellfile, ',')
     for n in l:spellfiles
	  if filereadable(expand(n)) && !filereadable(expand(n .. '.spl'))
		  \ || getftime(expand(n)) > getftime(expand(n .. '.spl'))
	       execute 'mkspell! ' .. n
	  endif
     endfor
     augroup nvimrc_Mkspell
	  autocmd!
	  autocmd BufWinEnter * call Mkspell()
     augroup END
endfunction

if v:vim_did_enter == 0
     call Mkspell()
endif

" {{{1 Commands

" Transform comma-separated or tab-separated lists into Lua table constructor
command -range=% -nargs=* Luatable <line1>,<line2>call Luatable(<f-args>)

function Luatable(operation = 'disamb', swap = 'noswap', format = 'csv') range
     if a:format == 'csv'
	  if a:swap == 'noswap'
	       silent! execute a:firstline .. ',' .. a:lastline .. 'substitute/^"\(.\{-}\)","\=\(.\{-}\)"\=$/\["\1"\] = "\2",'
	       silent! execute a:firstline .. ',' .. a:lastline .. 'substitute/^\([^\[].\{-}\),"\=\(.\{-}\)"\=$/\["\1"\] = "\2",'
	  elseif a:swap == 'swap'
	       silent! execute a:firstline .. ',' .. a:lastline .. 'substitute/^"\(.\{-}\)","\=\(.\{-}\)"\=$/\["\2"\] = "\1",'
	       silent! execute a:firstline .. ',' .. a:lastline .. 'substitute/^\([^\[].\{-}\),"\=\(.\{-}\)"\=$/\["\2"\] = "\1",'
	  endif
     elseif a:format == 'tab'
	  if a:swap == 'noswap'
	       execute a:firstline .. ',' .. a:lastline .. 'substitute/^\(.*\)\t\(.*\)$/["\1"] = "\2",'
	  elseif a:swap == 'swap'
	       execute a:firstline .. ',' .. a:lastline .. 'substitute/^\(.*\)\t\(.*\)$/["\2"] = "\1",'
	  endif
     endif
     execute 'normal' .. a:firstline .. "GO= {\<Esc>"
     execute 'normal =' .. (a:lastline + 1) .. 'G'
     execute 'normal' .. (a:lastline + 1) .. "Go}\<Esc>"
     normal ==
     " Find duplicate keys and disambiguate or concatenate
     for i in range(a:firstline + 1, a:lastline)
	  let l:key = matchstr(getline(i), '\["\(.*\)"\]')
	  if a:operation == 'disamb'
	       let l:variant = 2
	       for j in range(i + 1, a:lastline + 1)
		    let l:candidate = matchstr(getline(j), '\["\(.*\)"\]')
		    if l:candidate ==# l:key
			 execute j .. 'substitute/\["\(.*\)"\]/\["\1(' .. l:variant .. ')"\]'
			 let l:variant = l:variant + 1
		    endif
	       endfor
	       if l:variant > 2
		    execute i .. 'substitute/\["\(.*\)"\]/\["\1(1)"\]'
	       endif
	  elseif a:operation == 'concat'
	       let l:lines_del = 0
	       for j in range(i + 1, a:lastline + 1)
		    silent! let l:candidate = matchstr(getline(j - l:lines_del), '\["\(.*\)"\]')
		    if l:candidate ==# l:key
			 let l:match = matchstr(getline(j - l:lines_del), '=\s"\zs.*\ze",')
			 if l:match != ''
			      execute (j - l:lines_del) .. 'delete _'
			      let l:lines_del = l:lines_del + 1
			      execute 'normal' .. i .. 'G$F"i; ' .. l:match .. "\<Esc>"
			 endif
		    endif
	       endfor
	  endif
     endfor
     execute 'normal' .. a:firstline .. 'G^'
     startinsert
endfunction

" {{{1 Vim-plug

call plug#begin('~/.config/nvim/vim-plug')
     Plug 'lervag/vimtex'
     Plug 'roxma/nvim-yarp'
     Plug 'ncm2/ncm2'
     Plug 'jamessan/vim-gnupg'
call plug#end()

" {{{1 VimTeX settings

let g:vimtex_compiler_latexmk_engines = {'_' : '-xelatex'}
let g:vimtex_complete_close_braces = 1
let g:vimtex_view_method = 'skim'
let g:vimtex_view_skim_sync = 1
let g:vimtex_view_skim_reading_bar = 1

" Indent after `[` and `]`, not just `{` and `}`
let g:vimtex_indent_delims = {
     \ 'open' : ['{','['],
     \ 'close' : ['}',']'],
     \ 'close_indented' : 0,
     \ 'include_modified_math' : 1,
     \ }

" Do not indent after `ifbool`
let g:vimtex_indent_conditionals = {
     \ 'open': '\v%(\\newif)@<!\\if%(f>|field|name|numequal|thenelse|toggle|bool)@!',
     \ 'else': '\\else\>',
     \ 'close': '\\fi\>',
     \}

" Make Vim regain focus after inverse search
function! s:TexFocusVim() abort
     silent execute "!open -a Terminal"
     redraw!
endfunction
augroup vimtex_event_focus
     autocmd!
     autocmd User VimtexEventViewReverse call s:TexFocusVim()
augroup END

" Put directory with user configuration files at tip of `runtimepath`, so that
" they can take precedence over default VimTeX files
set runtimepath^=$HOME/.local/share/nvim/site/vimtex/

" {{{1 ncm2 configuration

set completeopt=noinsert,menuone,noselect
augroup my_cm_setup
     autocmd!
     autocmd BufEnter * call ncm2#enable_for_buffer()
     autocmd Filetype tex call ncm2#register_source({
	  \ 'name': 'vimtex',
	  \ 'priority': 8,
	  \ 'scope': ['tex'],
	  \ 'mark': 'tex',
	  \ 'word_pattern': '\w+',
	  \ 'complete_pattern': g:vimtex#re#ncm2,
	  \ 'on_complete': ['ncm2#on_complete#omni', 'vimtex#complete#omnifunc'],
	  \ })
augroup END

" {{{1 vim-gnupg configuration

let g:GPGExecutable = "PINENTRY_USER_DATA='' gpg --trust-model always"

" }}}1
