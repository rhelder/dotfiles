autocmd TermOpen * startinsert
command Arist execute 'vs ' .. arist
command Nvimrc execute 'vs ' .. nvimrc
command Reload execute 'so ' .. nvimrc
command Rhelder execute 'vs ' .. rhelder
command Spellcheck set invspell spelllang=en_us
command Terminal vs | terminal
command -nargs=* Vhelp vertical help <args>
command Zshrc execute 'vs ' .. zshrc
let &spellfile = "$HOME/.config/nvim/spell/en.utf-8.add"
let arist = "$HOME/Library/texmf/tex/latex/aristotelis/aristotelis.sty"
let db = "$HOME/Library/CloudStorage/Dropbox"
let g:python3_host_prog = "/usr/local/bin/python3"
let g:vim_indent_cont = shiftwidth() * 1
let maplocalleader = "\<Space>"
let nvimrc = "$HOME/.config/nvim/init.vim"
let rhelder = "$HOME/Library/texmf/tex/latex/rhelder/rhelder.sty"
let texmf = "$HOME/Library/texmf"
let ucb = "$HOME/Library/CloudStorage/Dropbox/UCBerkeley"
let vtc = "$HOME/.local/share/nvim/site/vimtex/autoload/vimtex/complete"
let zshrc = "$HOME/.zshrc"
set belloff=
set cursorline
set cursorlineopt=line
set guicursor=
set ignorecase
set mouse=
set noruler
set number
set report=0
set scrolloff=3
set shiftwidth=5
set smartcase
set softtabstop=5
set splitbelow
set splitright


""" Convert tab-separated lists (i.e., as copied/pasted from Excel spreadsheets) into Lua tables

function Luatable(operation = 'disamb', swap = 'noswap', format = "csv") range
     if a:format == "csv"
	  if a:swap == 'noswap'
	       silent! execute a:firstline .. "," .. a:lastline .. 's/^"\(.\{-}\)","\=\(.\{-}\)"\=$/\["\1"\] = "\2",'
	       silent! execute a:firstline .. "," .. a:lastline .. 's/^\([^\[].\{-}\),"\=\(.\{-}\)"\=$/\["\1"\] = "\2",'
	  elseif a:swap == 'swap'
	       silent! execute a:firstline .. "," .. a:lastline .. 's/^"\(.\{-}\)","\=\(.\{-}\)"\=$/\["\2"\] = "\1",'
	       silent! execute a:firstline .. "," .. a:lastline .. 's/^\([^\[].\{-}\),"\=\(.\{-}\)"\=$/\["\2"\] = "\1",'
	  endif
     elseif a:format == "tab"
	  if a:swap == 'noswap'
	       execute a:firstline .. "," .. a:lastline .. 's/^\(.*\)\t\(.*\)$/["\1"] = "\2",'
	  elseif a:swap == 'swap'
	       execute a:firstline .. "," .. a:lastline .. 's/^\(.*\)\t\(.*\)$/["\2"] = "\1",'
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

command -range=% -nargs=* Luatable silent <line1>,<line2>call Luatable(<f-args>)


""" Vimtex settings

let g:tex_flavor = "latex"
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


""" Vim-plug

call plug#begin('~/.config/nvim/vim-plug')
     Plug 'lervag/vimtex'
     Plug 'roxma/nvim-yarp'
     Plug 'ncm2/ncm2'
     Plug 'jamessan/vim-gnupg'
call plug#end()


"""ncm2 configuration

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


""" vim-gnupg configuration

let g:GPGExecutable = "PINENTRY_USER_DATA='' gpg --trust-model always"


""" Exit terminal mode when switching windows

augroup terminal_window_switch
     autocmd!
     autocmd TermEnter * tmap <C-W><C-W> <C-\><C-N><C-W><C-W>
     autocmd TermEnter * tmap <C-W>w <C-\><C-N><C-W>w
     autocmd TermEnter * tmap <C-W>j <C-\><C-N><C-W>j
     autocmd TermEnter * tmap <C-W>k <C-\><C-N><C-W>k
     autocmd TermEnter * tmap <C-W>h <C-\><C-N><C-W>h
     autocmd TermEnter * tmap <C-W>l <C-\><C-N><C-W>l
     autocmd TermLeave * tunmap <C-W><C-W>
     autocmd TermLeave * tunmap <C-W>w
     autocmd TermLeave * tunmap <C-W>j
     autocmd TermLeave * tunmap <C-W>k
     autocmd TermLeave * tunmap <C-W>h
     autocmd TermLeave * tunmap <C-W>l
augroup END


""" Map <Esc> to :noh without bell going off

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


" Rebuild .spl file whenever nvimrc is loaded

if filereadable(expand(&spellfile)) && !filereadable(expand(&spellfile .. '.spl'))
	\ || getftime(expand(&spellfile)) > getftime(expand(&spellfile .. '.spl'))
     execute 'mkspell! ' .. &spellfile
endif


""" Set defaults for various filetypes

augroup my_filetype_defaults
     autocmd!
     autocmd FileType * set textwidth=78
     autocmd FileType markdown set fo-=l 
     autocmd FileType csv set fo-=tc
     autocmd FileType tex set fo-=tc
     autocmd FileType tex set fo+=l
     autocmd FileType text,markdown,tex set linebreak
     autocmd FileType * set fo+=n
     autocmd FileType * let &formatlistpat = '^\s*\(\d\|\*\|+\|-\)\+[\]:.)}\t ]\s*'
     autocmd FileType * set smartindent
     autocmd FileType tex set nosmartindent
     autocmd FileType markdown source ~/mdView/mdView.vim
augroup END


"" Here's how to define Luatable as a command directly
" command -range=% LuaTableCommand  
"      \ execute "<line1>,<line2>" .. 's/^\(.*\)\t\(.*\)$/[''\1''] = ''\2'',' |
"      \ execute "noh" |
"      \ execute "normal <line1>GO= {\<Esc>" |
"      \ execute "normal =" .. (<line2> + 1) .. "G" |
"      \ execute "normal" .. (<line2> + 1) .. "Go}\<Esc>" |
"      \ execute "normal ==" |
"      \ execute "normal <line1>G^" |
"      \ execute "startinsert"
