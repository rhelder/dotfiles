" To-do
" * Learn how to map an operator, then use that to change surrounding quotes
"   (see `map-operator`)
" * Make changes in accordance with changes to zshrc

" {{{1 Options

let &formatlistpat = '^\s*\(\d\|\*\|+\|-\)\+[\]:.)}\t ]\s*'
set spellfile=~/.config/nvim/spell/en.utf-8.add,
            \~/.config/nvim/spell/de.utf-8.add
let g:python3_host_prog = '/usr/local/bin/python3'
set belloff=
set cursorline
set cursorlineopt=line
set expandtab
set foldlevelstart=0
set foldmethod=marker
set formatoptions+=n
set gdefault
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

" {{{1 Mappings

" Use `<Space>` as leader key
nnoremap <Space> <NOP>
let mapleader = "\<Space>"
let maplocalleader = "\<Space>"

" Source `.zshrc` mappings and shell variablse
source $XDG_CONFIG_HOME/nvim/zshrc.vim
nnoremap <Leader>sv <Cmd>source $MYVIMRC<CR>

" Open help
nnoremap \          <Cmd>vert help<CR>:help 
nnoremap <BS>       <Cmd>help<CR>:help 
nnoremap <Leader>h  :help 

" Open terminal
nnoremap <Leader>t <Cmd>vsplit<CR><Cmd>terminal<CR>

" Switch off search highlighting
nnoremap <silent> <Leader><Esc> <Cmd>noh<CR>

" Toggle `colorcolumn` on and off
nnoremap <expr> <Leader>w
            \ &colorcolumn ==# '' ?
            \ "<Cmd>setlocal colorcolumn=+1<CR>" :
            \ "<Cmd>setlocal colorcolumn=<CR>"

" Spell check
nnoremap <Leader>sl         :set spelllang=<C-R>=&spelllang<CR>
nnoremap <Leader>sp         <Cmd>setlocal spell!<CR>
nnoremap <expr> <Leader>sn  &spell ? "]sz=" : "<Leader>sn"
nnoremap <expr> <Leader>sN  &spell ? "[sz=" : "<Leader>sN"

" Navigation
noremap H       ^
noremap L       $
inoremap <BS>   <Nop>

" Move lines up or down
nnoremap - ddkP
nnoremap _ ddp

" Uppercase word
nnoremap <Leader>u viwUe

" Insert unique identifier
nnoremap <Leader>i :execute 'normal! i' ..
            \ strftime("%Y%m%d%H%M%S") .. "\<lt>Esc>"<CR>

" " Change surrounding quotes
" nnoremap <Leader>' vi"o<Esc>hr'gvo<Esc>lr'
" nnoremap <Leader>" vi'o<Esc>hr"gvo<Esc>lr"

" {{{2 Surround word or selection with delimiters
nnoremap <Leader>{ viw<Esc>`<i{<Esc>`>la}<Esc>%
nnoremap <Leader>} viw<Esc>`<i{<Esc>`>la}<Esc>%
nnoremap <Leader>[ viw<Esc>`<i[<Esc>`>la]<Esc>%
nnoremap <Leader>] viw<Esc>`<i[<Esc>`>la]<Esc>%
nnoremap <Leader>( viw<Esc>`<i(<Esc>`>la)<Esc>
nnoremap <Leader>) viw<Esc>`<i(<Esc>`>la)<Esc>
nnoremap <Leader>< viw<Esc>`<i<<Esc>`>la><Esc>%
nnoremap <Leader>> viw<Esc>`<i<<Esc>`>la><Esc>%
nnoremap <Leader>" viw<Esc>`<i"<Esc>`>la"<Esc>
nnoremap <Leader>' viw<Esc>`<i'<Esc>`>la'<Esc>
nnoremap <Leader>` viw<Esc>`<i`<Esc>`>la`<Esc>
vnoremap <Leader>{ <Esc>`<i{<Esc>`>la}<Esc>%
vnoremap <Leader>} <Esc>`<i{<Esc>`>la}<Esc>%
vnoremap <Leader>[ <Esc>`<i[<Esc>`>la]<Esc>%
vnoremap <Leader>] <Esc>`<i[<Esc>`>la]<Esc>%
vnoremap <Leader>( <Esc>`<i(<Esc>`>la)<Esc>
vnoremap <Leader>) <Esc>`<i(<Esc>`>la)<Esc>
vnoremap <Leader>< <Esc>`<i<<Esc>`>la><Esc>%
vnoremap <Leader>> <Esc>`<i<<Esc>`>la><Esc>%
vnoremap <Leader>" <Esc>`<i"<Esc>`>la"<Esc>
vnoremap <Leader>' <Esc>`<i'<Esc>`>la'<Esc>
vnoremap <Leader>` <Esc>`<i`<Esc>`>la`<Esc>
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

" {{{2 Open new note
nnoremap <Leader>nn <Cmd>call<SID>new_note()<CR>

function s:new_note()
    lcd ~/Documents/Notes
    execute 'edit ' .. strftime("%Y%m%d%H%M%S") .. '.md'
    execute "normal i---\r---\<Esc>"
    execute "normal Okeywords: \<Esc>"
    execute "normal Otitle: \<Esc>"
    execute 'normal Oid: ' .. strftime("%Y%m%d%H%M%S") .. "\<Esc>"
endfunction

" }}}2

" Insert mode abbreviations
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

" }}}1
" {{{1 Autocommands

" {{{2 Filetype defaults
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
    autocmd FileType zsh                setlocal iskeyword+=-
    " autocmd FileType markdown           source ~/scripts/mdView/mdView.vim
augroup END

" {{{2 Mappings
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

function s:comment(char)
    let l:patt = '^\s*' .. a:char
    if match(getline('.'), l:patt) ==# 0
        normal ^xx
    else
        execute 'normal I' .. a:char .. "\<Space>\<Esc>"
    endif
endfunction

" {{{2 Make spell files
" Rebuild `.spl` files upon initialization, and then subsequently whenever a
" buffer is loaded (or a hidden buffer is displayed) in a new window
function s:make_spell_files()
    let l:spellfiles = split(&spellfile, ',')
    for n in l:spellfiles
        if filereadable(expand(n)) && !filereadable(expand(n .. '.spl'))
                    \ || getftime(expand(n)) >=# getftime(expand(n .. '.spl'))
            execute 'mkspell! ' .. n
        endif
    endfor
    augroup nvimrc_Mkspell
        autocmd!
        autocmd BufWinEnter * execute &filetype ==# 'qf' ? '' : 'call <SID>make_spell_files()'
    augroup END
endfunction

if v:vim_did_enter ==# 0
    call s:make_spell_files()
endif

" }}}2

augroup nvimrc_autocommands
    autocmd!
    " Enter terminal mode and turn off line numbering when opening terminal
    autocmd TermOpen * startinsert
    autocmd TermOpen * set nonumber
    autocmd BufReadPost,BufNewFile $XDG_DATA_HOME/zsh/functions/*   set filetype=zsh
    autocmd BufReadPost,BufNewFile $HOME/.local/bin/*               set filetype=zsh
    autocmd ExitPre $XDG_CONFIG_HOME/zsh/.zshrc                     !sync-vz
augroup END

" }}}1
" {{{1 Commands

" {{{2 Insert numbered list

command -range -nargs=+ Enumerate <line1>,<line2>call <SID>enumerate(<args>)

let g:enumoptions = {
            \ 'space' : "\t",
            \ 'delim' : '.',
            \ }

function s:enumerate(
            \ begin, end='',
            \ space=g:enumoptions.space,
            \ delim=g:enumoptions.delim
            \ )

    " Forbid using both a range and an `end` argument at the same time
    if a:end !=# '' && a:firstline !=# a:lastline
        " Although function will be executed multiple times, echo only one
        " error message
        if a:lastline ==# line('.')
            echoerr 'No range allowed'
        endif
        return

    " If no range is given, insert list below current line
    elseif a:end !=# '' && a:firstline ==# a:lastline
        for i in range(a:begin, a:end)
            execute 'normal o' ..
                        \ i .. a:delim .. a:space .. "\<Esc>"
        endfor
    " If range is given, make text in that range into a list
    else
        execute 'normal I' ..
                    \ (line('.') - a:firstline + a:begin) ..
                    \ a:delim .. a:space .. "\<Esc>"
    endif
endfunction

" {{{2 Transform list of delimiter-separated values into Lua table constructor

command -range=% -nargs=* Luatable
            \ silent <line1>,<line2>call <SID>lua_table(<f-args>)

function s:lua_table(
            \ operation = 'disamb',
            \ swap = 'noswap',
            \ format = 'csv'
            \ )
            \ range

    " Check that arguments are valid
    if (a:operation ==# 'disamb' || a:operation ==# 'concat') &&
                \ (a:swap ==# 'noswap' || a:swap ==# 'swap') &&
                \ (a:format ==# 'csv' || a:format ==# 'tab')
    else
        echoerr 'Invalid argument'
        return
    endif

    " Transform list to Lua table constructor
    if a:swap ==# 'noswap'
        let l:replace_pattern = '/\["\1"\] = "\2",'
    elseif a:swap ==# 'swap'
        let l:replace_pattern = '/\["\2"\] = "\1",'
    endif
    if a:format ==# 'csv'
        let l:csv_pattern1 = '^"\(.\{-}\)","\=\(.\{-}\)"\=$'
        let l:csv_pattern2 = '^\([^\[].\{-}\),"\=\(.\{-}\)"\=$'
        silent! execute a:firstline .. ',' .. a:lastline ..
                    \ 'substitute/' .. l:csv_pattern1 .. l:replace_pattern
        silent! execute a:firstline .. ',' .. a:lastline ..
                    \ 'substitute/' .. l:csv_pattern2 .. l:replace_pattern
    elseif a:format ==# 'tab'
        let l:tab_pattern = '^\(.*\)\t\(.*\)$'
        execute a:firstline .. ',' .. a:lastline ..
                    \ 'substitute/' .. l:tab_pattern .. l:replace_pattern
    endif
    execute 'normal' .. a:firstline .. "GO= {\<Esc>"
    execute 'normal =' .. (a:lastline + 1) .. 'G'
    execute 'normal' .. (a:lastline + 1) .. "Go}\<Esc>"
    normal ==

    " Find duplicate keys and disambiguate or concatenate
    for i in range(a:firstline + 1, a:lastline)
        let l:key_pattern = '\["\(.*\)"\]'
        let l:key = matchstr(getline(i), l:key_pattern)

        if a:operation ==# 'disamb'
            let l:variant = 2
            for j in range(i + 1, a:lastline + 1)
                let l:candidate = matchstr(getline(j), l:key_pattern)
                if l:candidate ==# l:key
                    execute j .. 'substitute/' .. l:key_pattern ..
                                \ '/\["\1(' .. l:variant .. ')"\]'
                    let l:variant = l:variant + 1
                endif
            endfor
            if l:variant > 2
                execute i .. 'substitute/' .. l:key_pattern ..
                            \ '/\["\1(1)"\]'
            endif

        elseif a:operation ==# 'concat'
            let l:lines_del = 0
            for j in range(i + 1, a:lastline + 1)
                silent! let l:candidate =
                            \ matchstr(getline(j - l:lines_del),
                            \ l:key_pattern)
                if l:candidate ==# l:key
                    let l:match =
                                \ matchstr(getline(j - l:lines_del),
                                \ '=\s"\zs.*\ze",')
                    if l:match !=# ''
                        execute (j - l:lines_del) .. 'delete _'
                        let l:lines_del = l:lines_del + 1
                        execute 'normal' .. i ..
                                    \ 'G$F"i; ' .. l:match .. "\<Esc>"
                    endif
                endif
            endfor
        endif
    endfor

    " Return to first line and enter insert mode to enter table name
    execute 'normal' .. a:firstline .. 'G^'
    startinsert
endfunction

" }}}2

" }}}1
" {{{1 Vim-plug

call plug#begin()
    Plug 'lervag/vimtex'
    Plug 'roxma/nvim-yarp'
    Plug 'ncm2/ncm2'
    Plug 'jamessan/vim-gnupg'
call plug#end()

" {{{1 VimTeX settings

let g:vimtex_compiler_latexmk_engines = {'_' : '-xelatex'}
let g:vimtex_complete_close_braces = 1
let g:vimtex_view_method = 'skim'
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

" Indent `outline` environment like other list environments
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
            \]

" Make Vim regain focus after inverse search
function! s:TexFocusVim() abort
    silent execute "!open -a Terminal"
    redraw!
endfunction
augroup vimtex_event_focus
    autocmd!
    autocmd User VimtexEventViewReverse call s:TexFocusVim()
augroup END

" {{{1 ncm2 configuration

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

" {{{1 vim-gnupg configuration

let g:GPGExecutable = "PINENTRY_USER_DATA='' gpg --trust-model always"

" }}}1
