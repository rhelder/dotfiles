" to-do
" *  Standardize single vs. double quotes
" *  Reconsider mapping <Esc> to noh; also consider redefining substitute

" {{{1 Options

let &formatlistpat = '^\s*\(\d\|\*\|+\|-\)\+[\]:.)}\t ]\s*'
let &spellfile =
	\ '~/.config/nvim/spell/en.utf-8.add,
	\~/.config/nvim/spell/de.utf-8.add'
let g:python3_host_prog = "/usr/local/bin/python3"
let g:vim_indent_cont = shiftwidth() * 1
set belloff=
set cursorline
set cursorlineopt=line
set foldlevelstart=0
set foldmethod=marker
set formatoptions+=n
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

" {{{1 Filetype options

augroup nvimrc_filetype_defaults
     autocmd!
     autocmd FileType markdown set formatoptions-=l 
     autocmd FileType csv set formatoptions-=tc
     autocmd FileType tex set formatoptions-=tc
     autocmd FileType tex set formatoptions+=l
     autocmd FileType text,markdown,tex set linebreak
     autocmd FileType tex set nosmartindent
     autocmd FileType markdown source ~/mdView/mdView.vim
augroup END

" {{{1 Variables

let arist = "$HOME/Library/texmf/tex/latex/aristotelis/aristotelis.sty"
let db = "$HOME/Library/CloudStorage/Dropbox"
let nvimrc = "$HOME/.config/nvim/init.vim"
let rhelder = "$HOME/Library/texmf/tex/latex/rhelder/rhelder.sty"
let texmf = "$HOME/Library/texmf"
let ucb = "$HOME/Library/CloudStorage/Dropbox/UCBerkeley"
let vtc = "$HOME/.local/share/nvim/site/vimtex/autoload/vimtex/complete"
let zshrc = "$HOME/.zshrc"

" {{{1 Commands

command Arist execute 'vsplit ' .. arist
command Nvimrc execute 'vsplit ' .. nvimrc
command Reload execute 'so ' .. nvimrc
command Rhelder execute 'vsplit ' .. rhelder
command -nargs=? Spellcheck set spell! |
     \ if <q-args> != '' | set spelllang=<args> | endif
command Terminal vsplit | terminal
command -nargs=* Vhelp vertical help <args>
command Zshrc execute 'vsplit ' .. zshrc
" Convert tab-separated lists (i.e., as copied/pasted from Excel spreadsheets)
" into Lua tables
command -range=% -nargs=* Luatable <line1>,<line2>call Luatable(<f-args>)

function Luatable(operation = 'disamb', swap = 'noswap', format = "csv") range
     if a:format == "csv"
	  if a:swap == 'noswap'
	       silent! execute a:firstline .. "," .. a:lastline .. 'substitute/^"\(.\{-}\)","\=\(.\{-}\)"\=$/\["\1"\] = "\2",'
	       silent! execute a:firstline .. "," .. a:lastline .. 'substitute/^\([^\[].\{-}\),"\=\(.\{-}\)"\=$/\["\1"\] = "\2",'
	  elseif a:swap == 'swap'
	       silent! execute a:firstline .. "," .. a:lastline .. 'substitute/^"\(.\{-}\)","\=\(.\{-}\)"\=$/\["\2"\] = "\1",'
	       silent! execute a:firstline .. "," .. a:lastline .. 'substitute/^\([^\[].\{-}\),"\=\(.\{-}\)"\=$/\["\2"\] = "\1",'
	  endif
     elseif a:format == "tab"
	  if a:swap == 'noswap'
	       execute a:firstline .. "," .. a:lastline .. 'substitute/^\(.*\)\t\(.*\)$/["\1"] = "\2",'
	  elseif a:swap == 'swap'
	       execute a:firstline .. "," .. a:lastline .. 'substitute/^\(.*\)\t\(.*\)$/["\2"] = "\1",'
	  endif
     endif
     execute "normal" .. a:firstline .. "GO= {\<Esc>"
     execute "normal =" .. (a:lastline + 1) .. "G"
     execute "normal" .. (a:lastline + 1) .. "Go}\<Esc>"
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
     execute "normal" .. a:firstline .. "G^"
     startinsert
endfunction

" {{{1 Mappings

" Use <Space> as leader key
nnoremap <Space> <NOP>
let mapleader = "\<Space>"
let maplocalleader = "\<Space>"

nnoremap <Leader>u viwUe
nnoremap <Leader>ev <Cmd>vsplit $MYVIMRC<CR>
nnoremap <Leader>sv <Cmd>source $MYVIMRC<CR>
nnoremap <Leader>ez <Cmd>execute 'vsplit ' .. zshrc<CR>
nnoremap <Leader>sp <Cmd>set spell!<CR>
nnoremap <Leader>sl :set spelllang=

" Exit terminal mode when moving cursor to another window
augroup leave_terminal_window
     autocmd!
     autocmd TermEnter * tnoremap <C-W><C-W> <C-\><C-N><C-W><C-W>
     autocmd TermEnter * tnoremap <C-W>w <C-\><C-N><C-W>w
     autocmd TermEnter * tnoremap <C-W>j <C-\><C-N><C-W>j
     autocmd TermEnter * tnoremap <C-W>k <C-\><C-N><C-W>k
     autocmd TermEnter * tnoremap <C-W>h <C-\><C-N><C-W>h
     autocmd TermEnter * tnoremap <C-W>l <C-\><C-N><C-W>l
     autocmd TermLeave * tunmap <C-W><C-W>
     autocmd TermLeave * tunmap <C-W>w
     autocmd TermLeave * tunmap <C-W>j
     autocmd TermLeave * tunmap <C-W>k
     autocmd TermLeave * tunmap <C-W>h
     autocmd TermLeave * tunmap <C-W>l
augroup END

" Map <Esc> to :noh without bell going off
" Map keys that trigger search commands to set belloff=esc
cnoremap <expr><silent> <CR> getcmdtype() =~ '[/?]' ? '<CR>:set belloff=esc<CR>' : '<CR>'
nnoremap <silent> n :set belloff=esc<CR>n
nnoremap <silent> N :set belloff=esc<CR>N
nnoremap <silent> * :set belloff=esc<CR>*
nnoremap <silent> # :set belloff=esc<CR>#
nnoremap <silent> g* :set belloff=esc<CR>g*
nnoremap <silent> g# :set belloff=esc<CR>g#
" Map <Esc> to itself and turn bell back on
nnoremap <silent> <Esc> <Esc>:noh <Bar> set belloff=<CR>

" {{{1 Other autocommands

augroup nvimrc_autocommands
     autocmd!
     " Enter terminal mode when opening terminal
     autocmd TermOpen * startinsert
     " Rebuild .spl files both before entering window at startup and after
     " entering window of any subsequent new buffer
     autocmd FileType,BufWinEnter * call Mkspell()
augroup END

" Rebuild .spl files
function Mkspell()
     let l:spellfiles = split(&spellfile, ',')
     for n in l:spellfiles
	  if filereadable(expand(n)) && !filereadable(expand(n .. '.spl'))
		  \ || getftime(expand(n)) > getftime(expand(n .. '.spl'))
	       execute 'mkspell! ' .. n
	  endif
     endfor
endfunction

" {{{1 Vim-plug

call plug#begin('~/.config/nvim/vim-plug')
     Plug 'lervag/vimtex'
     Plug 'roxma/nvim-yarp'
     Plug 'ncm2/ncm2'
     Plug 'jamessan/vim-gnupg'
call plug#end()

" {{{1 Vimtex settings

let g:vimtex_compiler_latexmk_engines = {'_' : '-xelatex'}
let g:vimtex_complete_close_braces = 1
let g:vimtex_view_method = 'skim'
let g:vimtex_view_skim_sync = 1
let g:vimtex_view_skim_reading_bar = 1
let g:vimtex_indent_delims = {
     \ 'open' : ['{','['],
     \ 'close' : ['}',']'],
     \ 'close_indented' : 0,
     \ 'include_modified_math' : 1,
     \ }
let g:vimtex_indent_conditionals = {
     \ 'open': '\v%(\\newif)@<!\\if%(f>|field|name|numequal|thenelse|toggle|bool)@!',
     \ 'else': '\\else\>',
     \ 'close': '\\fi\>',
     \}
function! s:TexFocusVim() abort
     silent execute "!open -a Terminal"
     redraw!
endfunction
augroup vimtex_event_focus
     autocmd!
     autocmd User VimtexEventViewReverse call s:TexFocusVim()
augroup END
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
