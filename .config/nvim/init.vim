" [TODO]
" * Write mapping that creates new list item at line in insert mode (use <C-A>
"   after lervag)
" * Maybe modify formatlistpat to deal with lists in comments, like this one?
" * Add mapping to shift to child item with tab (and renumber subsequent items)
" * Add mapping to change label
" * If <C-U> deletes a label, renumber subsequent items
" * Known error: cw seems to not work sometimes in normal mode

" Options {{{1

let &formatlistpat = '\v^(\s{})\(?((\d+|\a+|#|\@\a*)[]:.)}]{1}|\*|\+|-)\s+'
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

" Source files
nnoremap <Leader>sv <Cmd>source $MYVIMRC<CR>
nnoremap <Leader>sf <Cmd>source %<CR>

" Open terminal in vertical split
nnoremap <Leader>t <Cmd>vsplit<CR><Cmd>terminal<CR>

" Sort case-insensitively
vnoremap <silent> <Leader>si :sort i<CR>

" Move lines up or down
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

    " Enable notes configuration in notes directory
    autocmd BufReadPost,BufNewFile $HOME/Documents/Notes/*.md
                \ let b:notes_enabled = 1

    " Run a script converting .zshrc aliases and shell variables into Vim
    " mappings and variables when exiting .zshrc
    autocmd BufWinLeave $XDG_CONFIG_HOME/zsh/.zshrc !sync-vz

    " Convert word lists to .spl files whenever entering a new buffer
    autocmd BufEnter * silent call s:make_spell_files()

    " Enter terminal mode and turn off line numbering when opening terminal
    autocmd TermOpen * startinsert
    autocmd TermOpen * set nonumber
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
    autocmd FileType markdown,gitcommit setlocal formatlistpat<
augroup END

augroup nvimrc_key_mappings " {{{2
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
    " Plug 'lervag/lists.vim'
    Plug 'ncm2/ncm2'
    Plug 'roxma/nvim-yarp'
    Plug 'wellle/targets.vim'
    Plug 'jamessan/vim-gnupg'
    Plug 'junegunn/vim-plug'
    Plug 'machakann/vim-sandwich'
    Plug 'lervag/vimtex'
call plug#end()

" Use vim-surround key mappings for vim-sandwich
runtime macros/sandwich/keymap/surround.vim

let g:GPGExecutable = 'PINENTRY_USER_DATA="" gpg --trust-model=always'

" }}}1

let s:sourced = 1

" Deleting and inserting list items {{{1

function! s:map(key, action, prefix = '') abort " {{{2
    execute 'nnoremap <buffer> <expr> ' .. a:prefix ..tolower(a:key) ..
                \ ' <SID>change_numbered_list(' ..
                \   string(a:prefix .. tolower(a:key)) .. ', ' ..
                \   string(a:action) .. ')'
    execute 'vnoremap <buffer> <expr> ' .. a:prefix .. tolower(a:key) ..
                \ ' <SID>change_numbered_list(' ..
                \   string(a:prefix .. tolower(a:key)) .. ', ' ..
                \   string(a:action) .. ')'
    execute 'nnoremap <buffer> <expr> ' .. a:prefix .. toupper(a:key) ..
                \ ' <SID>change_numbered_list(' ..
                \   string(a:prefix .. toupper(a:key)) .. ', ' ..
                \   string(a:action) .. ')'
    execute 'vnoremap <buffer> <expr> ' .. a:prefix .. toupper(a:key) ..
                \ ' <SID>change_numbered_list(' ..
                \   string(a:prefix .. toupper(a:key)) .. ', ' ..
                \   string(a:action) .. ')'
endfunction

" autocmd FileType text call s:map('c', 'delete')
" autocmd FileType text call s:map('d', 'delete')
" autocmd FileType text call s:map('p', 'insert')
" autocmd FileType text call s:map('p', 'insert', 'g')
" autocmd FileType text call s:map('p', 'insert', 'z')
" autocmd FileType text call s:map('p', 'insert', '[')
" autocmd FileType text call s:map('p', 'insert', ']')
" autocmd FileType text nnoremap <buffer> <expr> . <SID>change_numbered_list('.', '')
" autocmd FileType text inoremap <buffer> <expr> <CR> <SID>insert_list_line("\<CR>")
" autocmd FileType text nnoremap <buffer> <expr> o <SID>insert_list_line('o')
" autocmd FileType text nnoremap <buffer> <expr> O <SID>insert_list_line('O')

function! s:change_numbered_list(key, action) abort " {{{2
    if a:key ==# '.'
        if !exists('s:last_action') | return a:key | endif
        let l:action = s:last_action
    else
        let l:action = a:action
    endif

    if l:action ==# 'delete'
        let s:current_item = s:item_object('inner')
        if empty(s:current_item) | return a:key | endif
        let l:label = s:current_item.label
    elseif l:action ==# 'insert'
        let l:execute_register = eval('@' .. v:register)
        let l:matchlist = matchlist(l:execute_register, &formatlistpat)
        " [TODO]:
        " let l:matchlist = matchlist(l:execute_register,
                    " \ substitute(&formatlistpat, '\^', '(^|\\n)', ''))
        if empty(l:matchlist) | return a:key | endif
        let l:label = l:matchlist[2]
        " let l:label = l:matchlist[3]
    endif
    if l:label !~# '\v\d+' | return a:key | endif

    execute 'autocmd TextChanged <buffer> ++once call s:renumber_list(' ..
                \ string(l:action) .. ')'
    let s:last_action = l:action
    return a:key
endfunction

function! s:insert_list_line(key) abort " {{{2
    let l:current_item = s:item_object('inner')
    if empty(l:current_item)
        return a:key

    elseif a:key ==# 'O' && line('.') !=# l:current_item.line.start
        return a:key

    elseif a:key ==# "\<CR>" || a:key ==# 'o'
        if line('.') ==# l:current_item.line.start &&
                    \ line('.') !=# l:current_item.line.end
            let l:indent = ''
            for iteration in range(1, l:current_item.indent.item)
                let l:indent ..= ' '
            endfor

            return a:key .. l:indent
        elseif line('.') !=# l:current_item.line.end
            return a:key
        endif
    endif

    let l:label = l:current_item.label
    if l:label =~# '\v\d+'
        if a:key ==# "\<CR>" || a:key ==# 'o'
            let l:label = str2nr(l:label) + 1
        elseif a:key ==# 'O'
            let l:label = str2nr(l:label) - 1
            if !l:label | let l:label = 1 | endif
        endif
        let l:header = s:renumber_header(l:current_item, l:label)
        autocmd TextChangedI <buffer> ++once call s:renumber_list('insert')
    else
        let l:header = matchlist(getline(l:current_item.line.start),
                    \ &formatlistpat)[0]
    endif

    if getline('.') =~# '^\s'
        return a:key .. "\<C-U>" .. l:header
    else
        return a:key .. l:header
    endif
endfunction

function! s:renumber_list(action) abort " {{{2
    let l:current_item = s:item_object('inner')
    if empty(l:current_item) | return | endif
    " [FIXME] This is what is preventing renumbering if you delete first line
    " of multiline first item

    if a:action ==# 'delete'
        if l:current_item.indent ==# s:current_item.indent &&
                    \ l:current_item.label ==# s:current_item.label
            return
        endif
    endif

    let l:current_list = s:inner_list_object()
    let l:index = index(l:current_list.objects, l:current_item)
    if !l:index
        let l:label = 1
    else
        let l:prev_item = l:current_list.objects[l:index - 1]
        let l:label = l:prev_item.label + 1
    endif
    call s:renumber_line(l:current_item, l:label)

    if l:current_list.objects[-1] ==# l:current_item
        return
    else
        let l:next_item = l:current_list.objects[l:index + 1]
    endif

    let l:diff = (l:next_item.label - l:label) - 1
    let l:label = l:next_item.label - l:diff
    call s:renumber_line(l:next_item, l:label)

    for item in l:current_list.objects[l:index+2:-1]
        let l:label += 1
        call s:renumber_line(item, l:label)
    endfor
endfunction

function! s:renumber_line(item_object, label) abort " {{{2
    let l:header = s:renumber_header(a:item_object, a:label)
    let l:line = getline(a:item_object.line.start)
    let l:line = substitute(l:line, &formatlistpat, l:header, '')
    call setline(a:item_object.line.start, l:line)
endfunction

function! s:renumber_header(item_object, label) abort " {{{2
    let l:line = getline(a:item_object.line.start)
    let l:matchlist = matchlist(l:line, &formatlistpat)
    let l:header = substitute(l:matchlist[0], l:matchlist[2], a:label, '')
    if strlen(l:header) > a:item_object.indent.item
        let l:header = strpart(l:header, 0, a:item_object.indent.item)
    elseif strlen(l:header) < a:item_object.indent.item
        while strlen(l:header) < a:item_object.indent.item
            let l:header = l:header .. ' '
        endwhile
    endif
    return l:header
endfunction
" }}}2

" }}}1
