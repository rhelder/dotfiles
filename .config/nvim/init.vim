autocmd TermOpen * startinsert
command Arist execute 'vs ' .. arist
command Nvimrc execute 'vs ' .. nvimrc
command Reload execute 'so ' .. nvimrc
command Rhelder execute 'vs ' .. rhelder
command Spellcheck set spell spelllang=en_us
command Terminal vs | terminal
command Zshrc execute 'vs ' .. zshrc
let arist = "$HOME/Library/texmf/tex/latex/aristotelis/aristotelis.sty"
let db = "$HOME/Library/CloudStorage/Dropbox"
let g:python3_host_prog = "/usr/local/bin/python3"
let g:vim_indent_cont = shiftwidth() * 1
let nvimrc = "$HOME/.config/nvim/init.vim"
let rhelder = "$HOME/Library/texmf/tex/latex/rhelder/rhelder.sty"
let texmf = "$HOME/Library/texmf"
let ucb = "$HOME/Library/CloudStorage/Dropbox/UCBerkeley"
let vtc = "$HOME/.local/share/nvim/site/vimtex/autoload/vimtex/complete"
let zshrc = "$HOME/.zshrc"
set belloff=
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

function LuaTable(format = "csv") range
     if a:format == "csv"
	  execute a:firstline .. "," .. a:lastline .. 's/^"\(.\{-}\)","\=\(.\{-}\)"\=$/\["\1"\] = "\2"'
	  execute a:firstline .. "," .. a:lastline .. 's/^\([^\[].\{-}\),"\=\(.\{-}\)"\=$/\["\1"\] = "\2"'
	  execute "noh"
	  execute "normal" .. a:firstline .. "GO= {\<Esc>"
	  execute "normal =" .. (a:lastline + 1) .. "G"
	  execute "normal" .. (a:lastline + 1) .. "Go}\<Esc>"
	  normal ==
	  execute "normal" .. a:firstline .. "G^"
	  execute "startinsert"
     elseif a:format == "tab"
	  execute a:firstline .. "," .. a:lastline .. 's/^\(.*\)\t\(.*\)$/[''\1''] = ''\2'','
	  execute "noh"
	  execute "normal" .. a:firstline .. "GO= {\<Esc>"
	  execute "normal =" .. (a:lastline + 1) .. "G"
	  execute "normal" .. (a:lastline + 1) .. "Go}\<Esc>"
	  normal ==
	  execute "normal" .. a:firstline .. "G^"
	  execute "startinsert"
     endif
endfunction

" function Luatable() range
" endfunction

command -range=% -nargs=? LuaTable silent! <line1>,<line2>call LuaTable(<f-args>)


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


""" Use only yanked text for system clipboard

nnoremap y "*y
vnoremap y "*y
nnoremap Y "*Y
vnoremap Y "*Y
" Maybe also deleted text? Just not small deletions?


""" Set defaults for various filetypes

augroup my_filetype_defaults
     autocmd!
     autocmd FileType * set textwidth=78
     autocmd FileType text set fo+=n
     autocmd FileType markdown set fo-=l 
     autocmd FileType lua,vim,zsh set fo-=cro
     autocmd FileType text,markdown,tex set linebreak
     autocmd FileType * set smartindent
     autocmd FileType tex set nosmartindent
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
