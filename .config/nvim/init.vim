" Options {{{1

let &formatlistpat = '^\s*\(\d\|\*\|+\|-\)\+[\]:.)}\t ]\s*'
let g:python3_host_prog = '/usr/local/bin/python3'
set belloff=
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
set report=0
set scrolloff=3
set shiftwidth=4
set smartcase
set softtabstop=4
set splitbelow
set splitright

" Undo files
set undofile
set undodir=$HOME/.cache/vim/undo
if !isdirectory(&undodir)
  call mkdir(&undodir, 'p')
endif

" Only set options that are also set by FileType autocommands (or spelllang)
" the first time init.vim is sourced, so that the options are not overridden if
" init.vim is sourced again
if !exists('s:sourced')
    set formatoptions+=n
    set number
    set smartindent
    set spelllang=en_us
    set textwidth=79
endif

" Mappings {{{1

" Set space as leader key
nnoremap <Space> <NOP>
let mapleader = "\<Space>"
let maplocalleader = "\<Space>"

" Source .zshrc mappings and shell variables
source $XDG_CONFIG_HOME/nvim/zshrc.vim

" Source init.vim
nnoremap <Leader>sv <Cmd>source $MYVIMRC<CR>

" Open terminal in vertical split
nnoremap <Leader>t  <Cmd>vsplit<CR><Cmd>terminal<CR>

" Move lines up or down
nnoremap -          ddkP
nnoremap _          ddp

" Help
nnoremap \          <Cmd>vert help<CR>:help 
nnoremap <BS>       <Cmd>help<CR>:help 
nnoremap <Leader>h  :help 

" Display
nnoremap <silent> <Leader><Esc> <Cmd>noh<CR>
nnoremap <expr> <Leader>w
            \ &colorcolumn ==# ''
            \     ? "<Cmd>setlocal colorcolumn=+1<CR>"
            \     : "<Cmd>setlocal colorcolumn=<CR>"

" Spell
nnoremap <Leader>sl             :setlocal spelllang=
nnoremap <Leader>sp             <Cmd>setlocal spell!<CR>
nnoremap <expr> <Leader>sn      &spell ? "]sz=" : "<Leader>sn"
nnoremap <expr> <Leader>sN      &spell ? "[sz=" : "<Leader>sN"

" Notes
nnoremap <Leader>nj             <Cmd>call <SID>new_journal()<CR>
nnoremap <Leader>nn             <Cmd>call <SID>new_note()<CR>
nnoremap <Leader>ns             <Cmd>call <SID>search_notes()<CR>

function! s:new_note() abort " {{{2
    lcd ~/Documents/Notes
    let l:name = strftime("%Y%m%d%H%M%S")
    execute 'edit ' .. l:name .. '.md'
    execute "normal i---\r---\<Esc>"
    execute "normal Okeywords: \<Esc>"
    execute "normal Otitle: \<Esc>"
    execute 'normal Oid: ' .. l:name .. "\<Esc>"
endfunction

function! s:new_journal() abort " {{{2
    lcd $HOME/Documents/Notes
    execute 'edit ' .. strftime('%F') .. '.txt'
    if !filereadable(strftime('%F') .. '.txt')
        execute 'normal i' .. strftime('%A, %B %e, %Y') .. "\<Esc>"
        execute "normal 2o\<Esc>"
    endif
endfunction

function! s:search_notes() abort " {{{2
    lcd $HOME/Documents/Notes
    Rfv [[:digit:]]*.md
endfunction

" Text objects for next and last objects {{{2

" Sentences (can't figure out how to do 'last' sentence)
onoremap ans :<C-U>normal! )vas<CR>
onoremap ins :<C-U>normal! )vis<CR>
vnoremap ans :<C-U>normal! )vas<CR>
vnoremap ins :<C-U>normal! )vis<CR>

" Square brackets
onoremap an[ :<C-U>normal! f[va[<CR>
onoremap in[ :<C-U>normal! f[vi[<CR>
onoremap al[ :<C-U>normal! F]va[<CR>
onoremap il[ :<C-U>normal! F]vi[<CR>
onoremap an] :<C-U>normal! f[va[<CR>
onoremap in] :<C-U>normal! f[vi]<CR>
onoremap al] :<C-U>normal! F]va]<CR>
onoremap il] :<C-U>normal! F]vi]<CR>
vnoremap an[ :<C-U>normal! f[va[<CR>
vnoremap in[ :<C-U>normal! f[vi[<CR>
vnoremap al[ :<C-U>normal! F]va[<CR>
vnoremap il[ :<C-U>normal! F]vi[<CR>
vnoremap an] :<C-U>normal! f[va]<CR>
vnoremap in] :<C-U>normal! f[vi]<CR>
vnoremap al] :<C-U>normal! F]va]<CR>
vnoremap il] :<C-U>normal! F]vi]<CR>

" Parentheses
onoremap an( :<C-U>normal! f(va(<CR>
onoremap in( :<C-U>normal! f(vi(<CR>
onoremap al( :<C-U>normal! F)va(<CR>
onoremap il( :<C-U>normal! F)vi(<CR>
onoremap an) :<C-U>normal! f(va)<CR>
onoremap in) :<C-U>normal! f(vi)<CR>
onoremap al) :<C-U>normal! F)va)<CR>
onoremap il) :<C-U>normal! F)vi)<CR>
onoremap anb :<C-U>normal! f(vab<CR>
onoremap inb :<C-U>normal! f(vib<CR>
onoremap alb :<C-U>normal! F)vab<CR>
onoremap ilb :<C-U>normal! F)vib<CR>
vnoremap an( :<C-U>normal! f(va(<CR>
vnoremap in( :<C-U>normal! f(vi(<CR>
vnoremap al( :<C-U>normal! F)va(<CR>
vnoremap il( :<C-U>normal! F)vi(<CR>
vnoremap an) :<C-U>normal! f(va)<CR>
vnoremap in) :<C-U>normal! f(vi)<CR>
vnoremap al) :<C-U>normal! F)va)<CR>
vnoremap il) :<C-U>normal! F)vi)<CR>
vnoremap anb :<C-U>normal! f(vab<CR>
vnoremap inb :<C-U>normal! f(vib<CR>
vnoremap alb :<C-U>normal! F)vab<CR>
vnoremap ilb :<C-U>normal! F)vib<CR>

" Angle brackets
onoremap an< :<C-U>normal! f<va<<CR>
onoremap in< :<C-U>normal! f<vi<<CR>
onoremap al< :<C-U>normal! F>va<<CR>
onoremap il< :<C-U>normal! F>vi<<CR>
onoremap an> :<C-U>normal! f<va><CR>
onoremap in> :<C-U>normal! f<vi><CR>
onoremap al> :<C-U>normal! F>va><CR>
onoremap il> :<C-U>normal! F>vi><CR>
vnoremap an< :<C-U>normal! f<va<<CR>
vnoremap in< :<C-U>normal! f<vi<<CR>
vnoremap al< :<C-U>normal! F>va<<CR>
vnoremap il< :<C-U>normal! F>vi<<CR>
vnoremap an> :<C-U>normal! f<va><CR>
vnoremap in> :<C-U>normal! f<vi><CR>
vnoremap al> :<C-U>normal! F>va><CR>
vnoremap il> :<C-U>normal! F>vi><CR>

" Curly braces
onoremap an{ :<C-U>normal! f{va{<CR>
onoremap in{ :<C-U>normal! f{vi{<CR>
onoremap al{ :<C-U>normal! F}va{<CR>
onoremap il{ :<C-U>normal! F}vi{<CR>
onoremap an} :<C-U>normal! f{va}<CR>
onoremap in} :<C-U>normal! f{vi}<CR>
onoremap al} :<C-U>normal! F}va}<CR>
onoremap il} :<C-U>normal! F}vi}<CR>
onoremap anB :<C-U>normal! f{vaB<CR>
onoremap inB :<C-U>normal! f{viB<CR>
onoremap alB :<C-U>normal! F}vaB<CR>
onoremap ilB :<C-U>normal! F}viB<CR>
vnoremap an{ :<C-U>normal! f{va{<CR>
vnoremap in{ :<C-U>normal! f{vi{<CR>
vnoremap al{ :<C-U>normal! F}va{<CR>
vnoremap il{ :<C-U>normal! F}vi{<CR>
vnoremap an} :<C-U>normal! f{va}<CR>
vnoremap in} :<C-U>normal! f{vi}<CR>
vnoremap al} :<C-U>normal! F}va}<CR>
vnoremap il} :<C-U>normal! F}vi}<CR>
vnoremap anB :<C-U>normal! f{vaB<CR>
vnoremap inB :<C-U>normal! f{viB<CR>
vnoremap alB :<C-U>normal! F}vaB<CR>
vnoremap ilB :<C-U>normal! F}viB<CR>

" Double quotes
onoremap an" :<C-U>normal! f"f"va"<CR>
onoremap in" :<C-U>normal! f"f"vi"<CR>
onoremap al" :<C-U>normal! F"F"va"<CR>
onoremap il" :<C-U>normal! F"F"vi"<CR>
vnoremap an" :<C-U>normal! f"f"va"<CR>
vnoremap in" :<C-U>normal! f"f"vi"<CR>
vnoremap al" :<C-U>normal! F"F"va"<CR>
vnoremap il" :<C-U>normal! F"F"vi"<CR>

" Single quotes
onoremap an' :<C-U>normal! f'f'va'<CR>
onoremap in' :<C-U>normal! f'f'vi'<CR>
onoremap al' :<C-U>normal! F'F'va'<CR>
onoremap il' :<C-U>normal! F'F'vi'<CR>
vnoremap an' :<C-U>normal! f'f'va'<CR>
vnoremap in' :<C-U>normal! f'f'vi'<CR>
vnoremap al' :<C-U>normal! F'F'va'<CR>
vnoremap il' :<C-U>normal! F'F'vi'<CR>

" Backticks
onoremap an` :<C-U>normal! f`f`va`<CR>
onoremap in` :<C-U>normal! f`f`vi`<CR>
onoremap al` :<C-U>normal! F`F`va`<CR>
onoremap il` :<C-U>normal! F`F`vi`<CR>
vnoremap an` :<C-U>normal! f`f`va`<CR>
vnoremap in` :<C-U>normal! f`f`vi`<CR>
vnoremap al` :<C-U>normal! F`F`va`<CR>
vnoremap il` :<C-U>normal! F`F`vi`<CR>

" Insert mode abbreviations {{{2
iabbrev assortnment     assortment
iabbrev snd             and
iabbrev perseverence    perseverance
iabbrev ot              to
iabbrev nd              and
iabbrev sya             say
iabbrev teh             the
iabbrev fo              of
iabbrev wrold           world
iabbrev iwll            will
iabbrev delcare         declare

" }}}2

" Autocommands {{{1

augroup nvimrc_autocommands
    autocmd!

    " When opening a new file in ~/.local/bin or in
    " ~/.local/share/zsh/functions, set the filetype to zsh
    autocmd BufReadPost,BufNewFile $HOME/.local/bin/* set filetype=zsh
    autocmd BufReadPost,BufNewFile $XDG_DATA_HOME/zsh/functions/*
                \ set filetype=zsh

    " Run a script converting .zshrc aliases and shell variables into Vim
    " mappings and variables when exiting .zshrc
    autocmd BufWinLeave $XDG_CONFIG_HOME/zsh/.zshrc !sync-vz

    " Run MdviewConvert and build-index when exiting a note
    autocmd BufWinLeave $HOME/Documents/Notes/*.md call s:exit_note()
    autocmd BufModifiedSet $HOME/Documents/Notes/*.md ++once let s:modified = 1
    " Set flag so that s:run_build_index can force 'hit enter' prompt before
    " quitting
    autocmd ExitPre $HOME/Documents/Notes/*.md let s:exiting = 1

    " Convert word lists to .spl files whenever entering a new buffer
    autocmd BufEnter * silent call s:make_spell_files()

    " Enter terminal mode and turn off line numbering when opening terminal
    autocmd TermOpen * startinsert
    autocmd TermOpen * set nonumber
augroup END

function! s:exit_note() abort " {{{2
    if filereadable(expand('%')) && exists('s:modified')
        try
            echo 'Running MdviewConvert...'
            MdviewConvert

        catch /^Vim(echoerr):/
            echohl ErrorMsg
            for line in split(v:errmsg, '\n')
                echomsg line
            endfor
            echohl Type
            call input("\nPress ENTER or type command to continue")

        finally
            echohl None
            redraw
        endtry

        execute s:_run_build_index()
        if exists('s:exiting')
            echohl Type
            call input("\nPress ENTER or type command to continue")
            echohl None
        endif
    endif
endfunction

function! s:_run_build_index() abort " {{{2
    echo 'Running build-index...'

    let l:filtered_stderr = system('build-index')
    if len(l:filtered_stderr) > 0
        let l:stderr = split(l:filtered_stderr, '\n')

        return 'echohl WarningMsg | for line in ' .. string(l:stderr) ..
                    \ ' | echomsg line | endfor | echohl None'
    else
        return ''
    endif
    return ''
endfunction

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

" Filetype defaults {{{2
augroup nvimrc_filetype_defaults
    autocmd!
    autocmd FileType markdown           setlocal formatoptions-=l
    autocmd FileType csv                setlocal formatoptions-=tc
    autocmd FileType tex                setlocal formatoptions-=t
    autocmd FileType tex                setlocal formatoptions+=orl
    autocmd FileType text,markdown      setlocal nonumber textwidth=78
    autocmd FileType text,markdown,tex  setlocal linebreak
    autocmd BufWinEnter COMMIT_EDITMSG  setlocal nosmartindent textwidth=72
    autocmd FileType text,markdown,tex  setlocal nosmartindent
augroup END

" Mappings {{{2
augroup nvrimc_key_mappings
    autocmd!

    " Comment out lines according to filetype
    autocmd FileType vim nnoremap <buffer> <silent> <LocalLeader>c
                \ :call <SID>comment('"')<CR>
    autocmd FileType vim vnoremap <buffer> <silent> <LocalLeader>c
                \ :call <SID>comment('"')<CR>
    autocmd FileType zsh,conf nnoremap <buffer> <silent> <LocalLeader>c
                \ :call <SID>comment('#')<CR>
    autocmd FileType zsh,conf vnoremap <buffer> <silent> <LocalLeader>c
                \ :call <SID>comment('#')<CR>
    autocmd FileType tex nnoremap <buffer> <silent> <LocalLeader>c
                \ :call <SID>comment('%')<CR>
    autocmd FileType tex vnoremap <buffer> <silent> <LocalLeader>c
                \ :call <SID>comment('%')<CR>

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

function! s:comment(character) abort " {{{3
    let l:pattern = '^\s*' .. a:character
    if match(getline('.'), l:pattern) ==# 0
        normal ^xx
    else
        execute 'normal I' .. a:character .. "\<Space>\<Esc>"
    endif
endfunction
" }}}3

" }}}2

" vim-plug {{{1

call plug#begin()
    Plug '/opt/homebrew/opt/fzf'
    Plug 'ncm2/ncm2'
    Plug 'roxma/nvim-yarp'
    Plug 'jamessan/vim-gnupg'
    Plug 'junegunn/vim-plug'
    Plug 'machakann/vim-sandwich'
    Plug 'lervag/vimtex'
call plug#end()

" VimTeX settings {{{1

let g:vimtex_compiler_latexmk_engines = {'_' : '-xelatex'}
let g:vimtex_complete_close_braces = 1
let g:vimtex_view_method = 'skim'
let g:vimtex_view_skim_reading_bar = 1

" Indent after [ and ], not just { and }
let g:vimtex_indent_delims = {
            \ 'open' : ['{','['],
            \ 'close' : ['}',']'],
            \ 'close_indented' : 0,
            \ 'include_modified_math' : 1,
            \ }

" Do not indent after ifbool
let g:vimtex_indent_conditionals = {
            \ 'open': '\v%(\\newif)@<!\\if%(f>|field|name|numequal|thenelse|toggle|bool)@!',
            \ 'else': '\\else\>',
            \ 'close': '\\fi\>',
            \ }

" Indent outline environment like other list environments
let g:vimtex_indent_lists = [
            \ 'itemize',
            \ 'description',
            \ 'enumerate',
            \ 'thebibliography',
            \ 'outline',
            \ 'education',
            \ 'research',
            \ 'papers',
            \ 'talks',
            \ 'awards',
            \ 'service',
            \ ]

" Make Vim regain focus after inverse search
" (from https://www.ejmastnak.com/tutorials/vim-latex/pdf-reader/
" #refocus-vim-after-forward-search)
augroup nvimrc_vimtex_autocommands
    autocmd!
    autocmd User VimtexEventViewReverse call s:nvim_regain_focus()
augroup END

function! s:nvim_regain_focus() abort
    silent execute "!open -a Terminal"
    redraw!
endfunction

" ncm2 configuration {{{1

set completeopt=noinsert,menuone,noselect
augroup my_cm_setup
    autocmd!
    autocmd BufEnter *      call ncm2#enable_for_buffer()
    autocmd Filetype tex    call ncm2#register_source({
                \ 'name': 'vimtex',
                \ 'priority': 8,
                \ 'scope': ['tex'],
                \ 'mark': 'tex',
                \ 'word_pattern': '\w+',
                \ 'complete_pattern': g:vimtex#re#ncm2,
                \ 'on_complete': ['ncm2#on_complete#omni', 'vimtex#complete#omnifunc'],
                \ })
augroup END

" vim-gnupg configuration {{{1

let g:GPGExecutable = "PINENTRY_USER_DATA='' gpg --trust-model always"

" rfv configuration {{{1

function! s:insert_link(file) abort
    execute 'normal! a[' .. a:file .. "]\<Esc>"
    let l:url = substitute(a:file, '.md$', '.html', '')
    let l:cursor_position = getpos('.')
    if getline('$') =~ '^\[.*\]: .*'
        execute 'normal! Go[' .. a:file .. ']: ' .. l:url .. "\<Esc>"
    else
        execute "normal! Go\<CR>[" .. a:file .. ']: ' .. l:url .. "\<Esc>"
    endif
    call setpos('.', l:cursor_position)
endfunction

let g:rfv_action = {
            \ 'ctrl-v': 'vertical split',
            \ 'ctrl-x': 'split',
            \ 'ctrl-o': 'silent !md-open',
            \ 'ctrl-]': function('s:insert_link'),
            \ }

" }}}1

let s:sourced = 1
