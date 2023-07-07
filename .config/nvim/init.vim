autocmd FileType * set fo-=r fo-=o fo-=c
autocmd FileType * set smartindent
autocmd FileType tex set linebreak
autocmd FileType tex set nosmartindent
autocmd TermOpen * startinsert
command Spellcheck set spell spelllang=en_us
let $ARISTOTELIS = "/usr/local/texlive/texmf-local/tex/latex/aristotelis/aristotelis.sty"
let $DB = "~/Library/CloudStorage/Dropbox"
let $NVIMRC = "~/.config/nvim/init.vim"
let $TEMPLATE = "/usr/local/texlive/texmf-local/tex/latex/template/template.sty"
let $UCB = "~/Library/CloudStorage/Dropbox/UCBerkeley"
let $VTC = "~/.config/nvim/pack/plugins/start/vimtex/autoload/vimtex/complete"
let $ZSHRC = "~/.zshrc"
let g:python3_host_prog = "/usr/local/bin/python3"
let g:vim_indent_cont = 0
set belloff=
set clipboard=unnamed
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


"Convert tab-separated lists (i.e., as copied/pasted from Excel spreadsheets) into Lua tables
function Luatable() range
     execute a:firstline .. "," .. a:lastline .. 's/^\(.*\)\t\(.*\)$/[''\1''] = ''\2'','
     execute "noh"
     execute "normal" .. a:firstline .. "GO= {\<Esc>"
     execute "normal =" .. (a:lastline + 1) .. "G"
     execute "normal" .. (a:lastline + 1) .. "Go}\<Esc>"
     normal ==
     execute "normal" .. a:firstline .. "G^"
     execute "startinsert"
endfunction

command -range=% Luatable <line1>,<line2>call Luatable()


"" Vimtex settings

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
function! s:TexFocusVim() abort
     silent execute "!open -a Terminal"
     redraw!
endfunction
augroup vimtex_event_focus
     autocmd!
     autocmd User VimtexEventViewReverse call s:TexFocusVim()
augroup END


" Vim-plug

call plug#begin('~/.config/nvim/vim-plug')
     Plug 'lervag/vimtex'
     Plug 'roxma/nvim-yarp'
     Plug 'ncm2/ncm2'
call plug#end()


"ncm2 configuration

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


" Exit terminal mode when switching windows

augroup terminal_window_switch
     autocmd!
     autocmd TermEnter * tmap <C-W><C-W> <C-\><C-N><C-W><C-W>
     autocmd TermEnter * tmap <C-W>w <C-\><C-N><C-W><C-W>
     autocmd TermLeave * tunmap <C-W><C-W>
     autocmd TermLeave * tunmap <C-W>w
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
