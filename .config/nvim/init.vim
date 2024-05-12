" [TODO]
" * Force proper formatlistpat for filetype gitcommit (and check for other
"   disobedient filetypes)
" * Write mapping that creates new list item at line in insert mode (use <C-A>
"   after lervag)
" * Deal with child items vs parent items
" * Maybe modify formatlistpat to deal with lists in comments, like this one?

" Options {{{1

let &formatlistpat = '\v^(\s{})(\d+|\*|\+|-)[]:.)}]?\s+'
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
    autocmd FileType csv                setlocal formatoptions-=tc
    autocmd FileType text,markdown      setlocal nonumber textwidth=78
    autocmd FileType text,markdown      setlocal linebreak
    autocmd BufWinEnter COMMIT_EDITMSG  setlocal nosmartindent textwidth=72
    autocmd FileType text,markdown      setlocal nosmartindent
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

" Text objects for lists {{{1

onoremap <silent> il :<C-U>call <SID>inner_list_object('select')<CR>
vnoremap <silent> il :<C-U>call <SID>inner_list_object('select')<CR>

function! s:inner_list_object(action) abort " {{{2
    if getline('.') !~# s:formatlistpat() .. '|^\s+|^$'
        if a:action ==# 'select' | execute "normal! \<Esc>" | endif
        return {}
    endif

    let l:start = search(s:formatlistpat(), 'bcnW')
    if !l:start
        if a:action ==# 'select' | execute "normal! \<Esc>" | endif
        return {}
    endif

    let l:matchlist = matchlist(getline(l:start), s:formatlistpat())
    let l:indent = strlen(l:matchlist[0])

    let l:end = l:start
    let l:lnum = line('.')
    for line in range(l:start + 1, line('$'))
        if getline(line) =~# '\v^\s{' .. l:indent .. '}\S+'
            let l:end = line
        elseif getline(line) =~# '^\s*$'
            continue
        else
            break
        endif
    endfor

    if l:lnum > l:end
        if a:action ==# 'select' | execute "normal! \<Esc>" | endif
        return {}
    endif

    if a:action == 'select'
        let l:count = l:end - l:start
        call cursor(l:start, 1)
        execute 'normal! V0'
        if l:count | execute 'normal! ' .. l:count .. 'j' | endif
    elseif a:action == 'get'
        let s:inner_list_object = {
                    \ 'line': {
                    \   'start': l:start,
                    \   'end': l:end,
                    \   },
                    \ 'indent': {
                    \   'item': l:indent,
                    \   'label': strlen(l:matchlist[1]),
                    \   },
                    \ 'label': l:matchlist[2],
                    \ }
        return s:inner_list_object
    endif
endfunction

function! s:formatlistpat(label_indent = '') abort " {{{2
    return '^\v(\s{' .. a:label_indent .. '})(\d+|\*|\+|-)[]:.)}]?\s+'
endfunction
" }}}2

" Navigation for lists {{{1

nnoremap ]l <Cmd>call <SID>to_list('label', '', 'start')<CR>
nnoremap ]L <Cmd>call <SID>to_list('label', '', 'end')<CR>
nnoremap [l <Cmd>call <SID>to_list('label', 'b', 'start')<CR>
nnoremap [L <Cmd>call <SID>to_list('label', 'b', 'end')<CR>
nnoremap ]m <Cmd>call <SID>to_list('item', '', 'start')<CR>
nnoremap ]M <Cmd>call <SID>to_list('item', '', 'end')<CR>
nnoremap [m <Cmd>call <SID>to_list('item', 'b', 'start')<CR>
nnoremap [M <Cmd>call <SID>to_list('item', 'b', 'end')<CR>

function! s:to_list(indent, direction, position, label_indent = '') abort " {{{2
    let l:cursor_pos = getpos('.')

    let l:inner_list_object = s:inner_list_object('get')
    if empty(l:inner_list_object)
        if search(s:formatlistpat(a:label_indent), a:direction .. 'W')
            let l:inner_list_object = s:inner_list_object('get')
        else
            call setpos('.', l:cursor_pos)
            return 0
        endif

    else
        if a:direction ==# '' && a:position ==# 'start'
            if line('.') != l:inner_list_object.line.start ||
                        \ col('.') >= l:inner_list_object.indent[a:indent] + 1
                if search(s:formatlistpat(a:label_indent), 'W')
                    let l:inner_list_object = s:inner_list_object('get')
                else
                    call setpos('.', l:cursor_pos)
                    return 0
                endif
            endif

        elseif a:direction ==# '' && a:position ==# 'end'
            if line('.') == l:inner_list_object.line.end &&
                        \ col('.') >= col('$') - 1
                if search(s:formatlistpat(a:label_indent), 'W')
                    let l:inner_list_object = s:inner_list_object('get')
                else
                    call setpos('.', l:cursor_pos)
                    return 0
                endif
            endif

        elseif a:direction ==# 'b' && a:position ==# 'start'
            if line('.') == l:inner_list_object.line.start &&
                        \ col('.') <= l:inner_list_object.indent[a:indent] + 1 &&
                        \ col('.') != 1
                call search(s:formatlistpat(a:label_indent), 'bW')
            endif

            if search(s:formatlistpat(a:label_indent), 'bW')
                let l:inner_list_object = s:inner_list_object('get')
            else
                call setpos('.', l:cursor_pos)
                return 0
            endif

        elseif a:direction ==# 'b' && a:position ==# 'end'
            if line('.') != l:inner_list_object.line.start ||
                        \ col('.') != 1
                call search(s:formatlistpat(a:label_indent), 'bW')
            endif

            if search(s:formatlistpat(a:label_indent), 'bW')
                let l:inner_list_object = s:inner_list_object('get')
            else
                call setpos('.', l:cursor_pos)
                return 0
            endif
        endif
    endif

    if a:position ==# 'start'
        call cursor(l:inner_list_object.line.start,
                    \ l:inner_list_object.indent[a:indent] + 1)
    elseif a:position ==# 'end'
        call cursor(l:inner_list_object.line.end, v:maxcol)
    endif

    if getpos('.') == l:cursor_pos
        return 0
    else
        return 1
    endif
endfunction
" }}}2

" Deleting and inserting list items {{{1

function! s:map(key, action, prefix = '') abort " {{{2
    execute 'nnoremap <expr> ' .. a:prefix ..tolower(a:key) ..
                \ ' <SID>change_numbered_list(' ..
                \   string(a:prefix .. tolower(a:key)) .. ', ' ..
                \   string(a:action) .. ')'
    execute 'vnoremap <expr> ' .. a:prefix .. tolower(a:key) ..
                \ ' <SID>change_numbered_list(' ..
                \   string(a:prefix .. tolower(a:key)) .. ', ' ..
                \   string(a:action) .. ')'
    execute 'nnoremap <expr> ' .. a:prefix .. toupper(a:key) ..
                \ ' <SID>change_numbered_list(' ..
                \   string(a:prefix .. toupper(a:key)) .. ', ' ..
                \   string(a:action) .. ')'
    execute 'vnoremap <expr> ' .. a:prefix .. toupper(a:key) ..
                \ ' <SID>change_numbered_list(' ..
                \   string(a:prefix .. toupper(a:key)) .. ', ' ..
                \   string(a:action) .. ')'
endfunction

call s:map('c', 'delete')
call s:map('d', 'delete')
call s:map('p', 'insert')
call s:map('p', 'insert', 'g')
call s:map('p', 'insert', 'z')
call s:map('p', 'insert', '[')
call s:map('p', 'insert', ']')
nnoremap <expr> . <SID>change_numbered_list('.', '')
inoremap <expr> <CR> <SID>insert_list_line("\<CR>")
nnoremap <expr> o <SID>insert_list_line('o')
nnoremap <expr> O <SID>insert_list_line('O')

function! s:change_numbered_list(key, action) abort " {{{2
    if a:key == '.'
        if !exists('s:last_action') | return a:key | endif
        let l:action = s:last_action
    else
        let l:action = a:action
    endif

    if l:action ==# 'delete'
        let s:current_list_object = s:inner_list_object('get')
        if empty(s:current_list_object) | return a:key | endif
        let l:label = s:current_list_object.label
    elseif l:action ==# 'insert'
        let l:execute_register = eval('@' .. v:register)
        let l:matchlist = matchlist(l:execute_register, &formatlistpat)
        if empty(l:matchlist) | return a:key | endif
        let l:label = l:matchlist[2]
    endif
    if l:label !~# '\v\d+' | return a:key | endif

    execute 'autocmd TextChanged <buffer> ++once call s:renumber_list(' ..
                \ string(l:action) .. ')'
    let s:last_action = l:action
    return a:key
endfunction

function! s:insert_list_line(key) abort " {{{2
    let l:current_list_object = s:inner_list_object('get')
    if empty(l:current_list_object)
        return a:key

    elseif a:key ==# 'O' && line('.') != l:current_list_object.line.start
        return a:key

    elseif a:key ==# "\<CR>" || a:key ==# 'o'
        if line('.') == l:current_list_object.line.start &&
                    \ line('.') != l:current_list_object.line.end
            let l:indent = ''
            for iteration in range(1, l:current_list_object.indent.item)
                let l:indent ..= ' '
            endfor

            return a:key .. l:indent
        elseif line('.') != l:current_list_object.line.end
            return a:key
        endif
    endif

    let l:label = l:current_list_object.label
    if l:label =~# '\v\d+'
        if a:key ==# "\<CR>" || a:key == 'o'
            let l:label = str2nr(l:label) + 1
        elseif a:key ==# 'O'
            let l:label = str2nr(l:label) - 1
            if !l:label | let l:label = 1 | endif
        endif
        let l:header = s:renumber_header(l:current_list_object, l:label)
        autocmd TextChangedI <buffer> ++once call s:renumber_list('insert')
    else
        let l:header = matchlist(getline(l:current_list_object.line.start),
                    \ &formatlistpat)[0]
    endif

    if a:key ==# 'O'
        return a:key .. l:header
    elseif a:key ==# "\<CR>" || a:key ==# 'o'
        if line('.') == l:current_list_object.line.start
            return a:key .. l:header
        else
            return a:key .. "\<C-U>" .. l:header
        endif
    endif
endfunction

function! s:renumber_list(action) abort " {{{2
    let l:new_list_object = s:inner_list_object('get')
    if empty(l:new_list_object) | return | endif

    if a:action ==# 'delete'
        if l:new_list_object.indent == s:current_list_object.indent &&
                    \ l:new_list_object.label == s:current_list_object.label
            return
        endif
    endif

    let l:cursor_pos = getpos('.')

    if !s:to_list('label', 'b', 'end', l:new_list_object.indent.label)
        let l:prev_list_object = {}
    else
        let l:prev_list_object = s:inner_list_object('get')
        if l:new_list_object.line.start - l:prev_list_object.line.end != 1
            let l:prev_list_object = {}
        endif
    endif

    call setpos('.', l:cursor_pos)

    if !s:to_list('label', '', 'start', l:new_list_object.indent.label)
        let l:next_list_object = {}
    else
        let l:next_list_object = s:inner_list_object('get')
        if l:next_list_object.line.start - l:new_list_object.line.end != 1
            let l:next_list_object = {}
        endif
    endif

    call setpos('.', l:cursor_pos)

    if empty(l:prev_list_object)
        let l:label = 1
    else
        let l:label = l:prev_list_object.label + 1
    endif
    call s:renumber_line(l:new_list_object, l:label)

    if empty(l:next_list_object) | return | endif

    let l:diff = (l:next_list_object.label - l:label) - 1
    let l:label = l:next_list_object.label - l:diff
    call s:renumber_line(l:next_list_object, l:label)

    call s:to_list('label', '', 'start', l:new_list_object.indent.label)

    while s:to_list('label', '', 'start', l:new_list_object.indent.label)
        let l:prev_list_object = l:next_list_object
        let l:next_list_object = s:inner_list_object('get')

        if l:next_list_object.line.start - l:prev_list_object.line.end != 1
            break
        endif

        let l:label +=1
        call s:renumber_line(s:inner_list_object('get'), l:label)
    endwhile

    call setpos('.', l:cursor_pos)
endfunction

function! s:renumber_line(list_object, label) abort " {{{2
    let l:header = s:renumber_header(a:list_object, a:label)
    let l:line = getline(a:list_object.line.start)
    let l:line = substitute(l:line, &formatlistpat, l:header, '')
    call setline(a:list_object.line.start, l:line)
endfunction

function! s:renumber_header(list_object, label) abort " {{{2
    let l:line = getline(a:list_object.line.start)
    let l:matchlist = matchlist(l:line, s:formatlistpat())
    let l:header = substitute(l:matchlist[0], l:matchlist[2], a:label, '')
    if strlen(l:header) > a:list_object.indent.item
        let l:header = strpart(l:header, 0, a:list_object.indent.item)
    elseif strlen(l:header) < a:list_object.indent.item
        while strlen(l:header) < a:list_object.indent.item
            let l:header = l:header .. ' '
        endwhile
    endif
    return l:header
endfunction
" }}}2

" }}}1
