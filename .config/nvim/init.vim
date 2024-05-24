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

" Text objects for lists {{{1

onoremap <silent> al :<C-U>call <SID>outer_list_object(1)<CR>
vnoremap <silent> al :<C-U>call <SID>outer_list_object(1)<CR>
onoremap <silent> il :<C-U>call <SID>inner_list_object(1)<CR>
vnoremap <silent> il :<C-U>call <SID>inner_list_object(1)<CR>
onoremap <silent> am :<C-U>call <SID>item_object('outer', 1)<CR>
vnoremap <silent> am :<C-U>call <SID>item_object('outer', 1)<CR>
onoremap <silent> im :<C-U>call <SID>item_object('inner', 1)<CR>
vnoremap <silent> im :<C-U>call <SID>item_object('inner', 1)<CR>

function! s:outer_list_object(select = 0, item = '') abort " {{{2
    let l:inner_list = s:inner_list_object(0, a:item)
    if empty(l:inner_list)
        if a:select | execute "normal! \<Esc>" | endif
        return {}
    endif

    if empty(l:inner_list.parents)
        let l:outer_list_object = s:get_list()
        let l:outer_list_object.type = l:inner_list.type
        let l:outer_list_object.parents = l:inner_list.parents
        let l:outer_list_object.children = l:inner_list.children

        if a:select
            call s:_select_range(l:outer_list_object.objects[0].line.start,
                        \ l:outer_list_object.objects[-1].line.end)
        endif
        return l:outer_list_object
    endif

    let l:outer_list_object = s:inner_list_object().parents[0]

    for item in l:outer_list_object.objects
        let item.parents = s:get_parents(item)
        let item.children = s:get_children(item)
    endfor

    let l:outer_list_object.parents = []
    for item in l:outer_list_object.objects[0].parents
        let l:parent = s:get_list(item)
        let l:parent.type = s:get_list_type(l:parent)
        call add(l:outer_list_object.parents, l:parent)
    endfor

    let l:outer_list_object.children = []
    for item in l:outer_list_object.objects
        call add(l:outer_list_object.children, item.children)
    endfor


    if a:select
        call s:_select_range(l:outer_list_object.objects[0].line.start,
                    \ l:outer_list_object.objects[-1].line.end)
    endif
    return l:outer_list_object
endfunction

function! s:inner_list_object(select = 0, item = '') abort " {{{2
    let l:list_object = s:get_list(a:item)
    if empty(l:list_object)
        if a:select | execute "normal! \<Esc>" | endif
        return {}
    endif

    let l:inner_list_object = {}
    let l:inner_list_object.objects = []
    for item in l:list_object.objects
        call add(l:inner_list_object.objects, s:item_object('inner', 0, item))
    endfor
    let l:inner_list_object.type = s:get_list_type(l:inner_list_object)

    let l:inner_list_object.parents = []
    for item in l:inner_list_object.objects[0].parents
        let l:parent = s:get_list(item)
        let l:parent.type = s:get_list_type(l:parent)
        call add(l:inner_list_object.parents, l:parent)
    endfor

    let l:inner_list_object.children = []
    for item in l:inner_list_object.objects
        call add(l:inner_list_object.children, item.children)
    endfor

    if a:select
        call s:_select_range(l:inner_list_object.objects[0].line.start,
                    \ l:inner_list_object.objects[-1].line.end)
    endif
    return l:inner_list_object
endfunction

function! s:get_list_type(list) abort " {{{2
    if a:list.objects[0].label =~# '\v\d+[]:.)}]{1}'
        let l:type = 'arabic'
    elseif a:list.objects[0].label =~# '\v[IVXLCDM]+[]:.)}]{1}'
        let l:type = 'Roman'
    elseif a:list.objects[0].label =~# '\v[ivxlcdm]+[]:.)}]{1}'
        let l:type = 'roman'
    elseif a:list.objects[0].label =~# '\v\u[]:.)}]{1}'
        let l:type = 'Alpha'
    elseif a:list.objects[0].label =~# '\v\l[]:.)}]{1}'
        let l:type = 'alpha'
    elseif a:list.objects[0].label =~# '\v#[]:.)}]{1}'
        let l:type = 'fancy'
    elseif a:list.objects[0].label =~# '\v\@\a+[]:.)}]{1}'
        let l:type = 'example'
    elseif a:list.objects[0].label =~# '\v[-*+]'
        let l:type = 'unordered'
    endif
    return l:type
endfunction

function! s:get_list(item = '') abort " {{{2
    if !empty(a:item)
        let l:current_item = a:item
    else
        let l:current_item = s:get_item()
    endif
    if empty(l:current_item) | return {} | endif
    let l:list = {'objects': []}
    call add(l:list.objects, l:current_item)

    let l:cursor_pos = getpos('.')
    call cursor(l:current_item.line.start, 1)
    while search(s:formatlistpat(l:list.objects[0].indent.label), 'bW')
        let l:prev_item = s:get_item()
        if l:current_item.line.start - l:prev_item.line.end !=# 1
            break
        endif
        call add(l:list.objects, l:prev_item)
        let l:current_item = l:prev_item
    endwhile

    call reverse(l:list.objects)

    let l:current_item = l:list.objects[-1]
    call cursor(l:current_item.line.start, v:maxcol)
    while search(s:formatlistpat(l:list.objects[0].indent.label), 'W')
        let l:next_item = s:get_item()
        if l:next_item.line.start - l:current_item.line.end !=# 1
            break
        endif
        call add(l:list.objects, l:next_item)
        let l:current_item = l:next_item
    endwhile

    call setpos('.', l:cursor_pos)
    return l:list
endfunction

function! s:item_object(scope, select = 0, item = '') abort " {{{2
    if !empty(a:item)
        let l:item_object = a:item
    else
        let l:item_object = s:get_item()
    endif

    if empty(l:item_object)
        if a:select | execute "normal! \<Esc>" | endif
        return {}
    endif

    let l:item_object.parents = s:get_parents(l:item_object)
    let l:item_object.children = s:get_children(l:item_object)

    if a:scope ==# 'inner'
        let l:item_object.line.end = s:inner_item_end(l:item_object)
    elseif a:scope ==# 'outer'
        if !empty(l:item_object.parents)
            let l:start = l:item_object.parents[0].line.start
        else
            let l:start = l:item_object.line.start
        endif

        let l:cursor_pos = getpos('.')
        call cursor(l:start, v:maxcol)
        let l:end = s:get_item().line.end
        let l:matchlist = matchlist(getline('.'), &formatlistpat)
        call setpos('.', l:cursor_pos)

        let l:item_object = {
                    \ 'line': {
                    \   'start': l:start,
                    \   'end': l:end,
                    \   },
                    \ 'indent': {
                    \   'item': strlen(l:matchlist[0]),
                    \   'label': strlen(l:matchlist[1]),
                    \   },
                    \ 'label': l:matchlist[2],
                    \ 'parents': l:item_object.parents[1:],
                    \ }
    endif

    if a:select
        call s:_select_range(l:item_object.line.start,
                    \ l:item_object.line.end)
    endif
    return l:item_object
endfunction

function! s:get_children(item) abort " {{{2
    let a:item.children = []

    let l:cursor_pos = getpos('.')
    call cursor(a:item.line.start, v:maxcol)

    let l:label_indent = a:item.indent.label + 1
    while search(s:formatlistpat(l:label_indent .. ','), 'W', a:item.line.end)
        let l:child = s:get_list()
        let l:child.type = s:get_list_type(l:child)
        call add(a:item.children, l:child)
        let l:label_indent = s:get_item().indent.label + 1
    endwhile

    call setpos('.', l:cursor_pos)
    return a:item.children
endfunction

function! s:get_parents(item) abort " {{{2
    let a:item.parents = []

    if !a:item.indent.label
        return a:item.parents
    endif

    let l:cursor_pos = getpos('.')
    call cursor(a:item.line.start, v:maxcol)

    let l:label_indent = a:item.indent.label - 1
    while search(s:formatlistpat('0,' .. l:label_indent), 'bW')
        let l:prev_item = s:get_item()
        if l:prev_item.line.end < a:item.line.end
            break
        endif

        call add(a:item.parents, l:prev_item)

        if !l:prev_item.indent.label
            break
        endif

        let l:label_indent = l:prev_item.indent.label - 1
    endwhile

    call setpos('.', l:cursor_pos)
    return a:item.parents
endfunction

function! s:inner_item_end(item) abort " {{{2
    let l:start = a:item.line.start
    let l:end = l:start
    for lnum in range(a:item.line.start + 1, a:item.line.end)
        let l:line = getline(lnum)
        if l:line =~# s:formatlistpat(a:item.indent.item)
            continue
        elseif l:line =~# '\v^\s{' .. (a:item.indent.item + 1) .. ',}\S+'
            continue
        elseif l:line =~# '\v^\s{' .. a:item.indent.item .. '}\S+'
            let l:end = lnum
        else
            break
        endif
    endfor
    return l:end
endfunction

function! s:get_item() abort " {{{2
    let l:line = getline('.')
    let l:matchlist = matchlist(l:line, &formatlistpat)
    if !empty(l:matchlist)
        let l:start = line('.')
        let l:indent = strlen(l:matchlist[0])

    else
        let l:indent = matchend(l:line, '\s*')

        let l:cursor_pos = getpos('.')
        while search(&formatlistpat, 'bW')
            let l:matchlist = matchlist(getline('.'), &formatlistpat)
            if strlen(l:matchlist[0]) ==# l:indent
                let l:start = line('.')
                break
            endif
        endwhile
        call setpos('.', l:cursor_pos)

        if !exists('l:start')
            return {}
        endif
    endif

    let l:end = l:start
    for lnum in range(l:start + 1, line('$'))
        let l:line = getline(lnum)
        if l:line =~# '^\s*$'
            if exists('l:blank_line') | break | endif
            let l:blank_line = 1
            continue
        elseif l:line =~# '\v^\s{' .. l:indent .. ',}\S+'
            let l:end = lnum
        else
            break
        endif
    endfor
    if line('.') > l:end
        return {}
    endif

    let l:item = {
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
    return l:item
endfunction

function! s:_select_range(start, end) abort " {{{2
    let l:count = a:end - a:start
    call cursor(a:start, 1)
    execute 'normal! V0'
    if l:count | execute 'normal! ' .. l:count .. 'j' | endif
endfunction

function! s:formatlistpat(label_indent = '') abort " {{{2
    return substitute(&formatlistpat,
                \ '\\s{}', '\\s{' .. a:label_indent .. '}', '')
endfunction
" }}}2

" Navigation for lists {{{1

nnoremap ]l <Cmd>call <SID>to_list('', 'start')<CR>
nnoremap ]L <Cmd>call <SID>to_list('', 'end')<CR>
nnoremap [l <Cmd>call <SID>to_list('b', 'start')<CR>
nnoremap [L <Cmd>call <SID>to_list('b', 'end')<CR>
nnoremap ]b <Cmd>call <SID>to_item('label', '', 'start')<CR>
nnoremap ]B <Cmd>call <SID>to_item('label', '', 'end')<CR>
nnoremap [b <Cmd>call <SID>to_item('label', 'b', 'start')<CR>
nnoremap [B <Cmd>call <SID>to_item('label', 'b', 'end')<CR>
nnoremap ]m <Cmd>call <SID>to_item('item', '', 'start')<CR>
nnoremap ]M <Cmd>call <SID>to_item('item', '', 'end')<CR>
nnoremap [m <Cmd>call <SID>to_item('item', 'b', 'start')<CR>
nnoremap [M <Cmd>call <SID>to_item('item', 'b', 'end')<CR>

function! s:to_list(direction, to, label_indent = '') abort " {{{2
    let [l:idx, l:col] = s:whither(a:to)

    let l:current_list = s:inner_list_object()
    if empty(l:current_list)
        call search(s:formatlistpat(a:label_indent), a:direction .. 'W')
        let l:current_list = s:inner_list_object()
        call cursor(l:current_list.objects[l:idx].line[a:to], l:col)
        return
    endif

    let l:lines = s:get_lines(a:to, l:current_list)
    if s:to_line(a:direction, a:to, l:lines) | return | endif

    if !empty(l:current_list.parents)
        let l:current_list = l:current_list.parents[-1]
    endif

    let l:cursor_pos = getpos('.')
    if a:direction ==# ''
        call cursor(l:current_list.objects[-1].line.end, v:maxcol)
    elseif a:direction ==# 'b'
        call cursor(l:current_list.objects[0].line.start, 1)
    endif
    if search(s:formatlistpat(a:label_indent), a:direction .. 'W')
        if a:direction ==# '' && a:to ==# 'start'
            return
        elseif a:direction ==# 'b' && a:to ==# 'end'
            call cursor(s:inner_list_object().objects[-1].line.end, v:maxcol)
            return
        endif

        let l:lines = s:get_lines(a:to, s:inner_list_object())
        call s:to_line(a:direction, a:to, l:lines)
    else
        call setpos('.', l:cursor_pos)
    endif
endfunction

function! s:to_line(direction, to, lines) abort " {{{3
    if a:direction ==# 'b' | call reverse(a:lines) | endif
    if a:to ==# 'start'
        let l:positions = map(a:lines, '[v:val, s:indent(v:val) + 1]')
    elseif a:to ==# 'end'
        let l:positions = map(a:lines, '[v:val, v:maxcol]')
    endif

    let l:lnum = line('.')
    for l:pos in l:positions
        if a:direction ==# ''
            if a:to ==# 'end' &&
                        \ (l:pos[0] ==# l:lnum && col('.') < (col('$') - 1))
                call cursor(l:pos)
                return 1
            elseif l:pos[0] > l:lnum
                call cursor(l:pos)
                return 1
            endif
        elseif a:direction ==# 'b'
            if a:to ==# 'start' &&
                        \ (l:pos[0] ==# l:lnum && col('.') > l:pos[1])
                call cursor(l:pos)
                return 1
            elseif l:pos[0] < l:lnum
                call cursor(l:pos)
                return 1
            endif
        endif
    endfor
    return 0
endfunction

function! s:indent(line) abort " {{{3
    return match(getline(a:line), '\S')
endfunction

function! s:get_lines(to, list) abort " {{{3
    let [l:idx, l:col] = s:whither(a:to)

    let l:lines = []
    for parent in a:list.parents
        if empty(a:list.parents) | break | endif
        let l:inner_parent_list = s:inner_list_object(0, parent.objects[0])
        call add(l:lines, l:inner_parent_list.objects[l:idx].line[a:to])
        call reverse(l:lines)
        for children in l:inner_parent_list.children
            for child in children
                call add(l:lines, child.objects[l:idx].line[a:to])
            endfor
        endfor
    endfor

    if empty(l:lines)
        call add(l:lines, a:list.objects[l:idx].line[a:to])
    endif

    for children in a:list.children
        for child in children
            call add(l:lines, child.objects[l:idx].line[a:to])
        endfor
    endfor

    return uniq(sort(l:lines, 'n'))
endfunction

function! s:whither(to) abort " {{{3
    if a:to ==# 'start'
        let l:idx = 0
        let l:col = 1
    elseif a:to ==# 'end'
        let l:idx = -1
        let l:col = v:maxcol
    endif

    return [l:idx, l:col]
endfunction

function! s:jump_cursor(...) abort " {{{3
    normal! m`
    if a:0 ==# 1
        call cursor(a:1)
    elseif a:0 ==# 2
        call cursor(a:1, a:2)
    elseif a:0 ==# 3
        call cursor(a:1, a:2, a:3)
    endif
endfunction
" }}}3

function! s:to_item(indent, direction, to, label_indent = '') abort " {{{2
    let l:cursor_pos = getpos('.')

    let l:inner_item = s:item_object('inner')
    if empty(l:inner_item)
        if search(s:formatlistpat(a:label_indent), a:direction .. 'W')
            let l:inner_item = s:item_object('inner')
        else
            call setpos('.', l:cursor_pos)
            return 0
        endif

    else
        if a:direction ==# '' && a:to ==# 'start'
            if line('.') !=# l:inner_item.line.start ||
                        \ col('.') >= l:inner_item.indent[a:indent] + 1
                if search(s:formatlistpat(a:label_indent), 'W')
                    let l:inner_item = s:item_object('inner')
                else
                    call setpos('.', l:cursor_pos)
                    return 0
                endif
            endif

        elseif a:direction ==# '' && a:to ==# 'end'
            if line('.') ==# l:inner_item.line.end &&
                        \ col('.') >= col('$') - 1
                if search(s:formatlistpat(a:label_indent), 'W')
                    let l:inner_item = s:item_object('inner')
                else
                    call setpos('.', l:cursor_pos)
                    return 0
                endif
            endif

        elseif a:direction ==# 'b' && a:to ==# 'start'
            if line('.') ==# l:inner_item.line.start &&
                        \ col('.') <= l:inner_item.indent[a:indent] + 1 &&
                        \ col('.') !=# 1
                call search(&formatlistpat, 'bW')
            endif

            if search(s:formatlistpat(a:label_indent), 'bW')
                let l:inner_item = s:item_object('inner')
            else
                call setpos('.', l:cursor_pos)
                return 0
            endif

        elseif a:direction ==# 'b' && a:to ==# 'end'
            if line('.') !=# l:inner_item.line.start || col('.') !=# 1
                call search(&formatlistpat, 'bW')
            endif

            if search(s:formatlistpat(a:label_indent), 'bW')
                let l:inner_item = s:item_object('inner')
            else
                call setpos('.', l:cursor_pos)
                return 0
            endif
        endif
    endif

    if a:to ==# 'start'
        call cursor(l:inner_item.line.start, l:inner_item.indent[a:indent] + 1)
    elseif a:to ==# 'end'
        call cursor(l:inner_item.line.end, v:maxcol)
    endif

    if getpos('.') ==# l:cursor_pos
        return 0
    else
        return 1
    endif
endfunction
" }}}2

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
" Roman numerals {{{1

function! s:arabic2roman(integer, case) abort " {{{2
    let l:digits = split(a:integer, '\zs')
    let l:numeral = ''
    for digit in l:digits
        if len(l:digits) ==# 4 && digit > 3
            echohl ErrorMsg
            echomsg 'No Roman numerals above 3999'
            echohl None
            return
        endif

        if len(l:digits) ==# 4
            let l:one = 'M'
        elseif len(l:digits) ==# 3
            let l:one = 'C'
            let l:five = 'D'
            let l:ten = 'M'
        elseif len(l:digits) ==# 2
            let l:one = 'X'
            let l:five = 'L'
            let l:ten = 'C'
        elseif len(l:digits) ==# 1
            let l:one = 'I'
            let l:five = 'V'
            let l:ten = 'X'
        endif

        if digit ==# 4 && len(l:digits) < 3
            let l:numeral ..= l:one .. l:five
        elseif digit ==# 9 && len(l:digits) < 3
            let l:numeral ..= l:one .. l:ten
        elseif digit < 5
            let l:numeral ..= ''
            for iteration in range(1, digit)
                let l:numeral ..= l:one
            endfor
        elseif digit ==# 5
            let l:numeral ..= l:five
        elseif digit > 5
            let l:numeral ..= l:five
            for iteration in range(6, digit)
                let l:numeral ..= l:one
            endfor
        endif
        call remove(l:digits, 0)
    endfor

    execute 'let l:numeral = to' .. a:case .. '(' .. string(l:numeral).. ')'
    return l:numeral
endfunction

function! s:roman2arabic(numeral) abort " {{{2
    let M = 1000
    let D = 500
    let C = 100
    let L = 50
    let X = 10
    let V = 5
    let I = 1
    let m = 1000
    let d = 500
    let c = 100
    let l = 50
    let x = 10
    let v = 5
    let i = 1

    if strlen(a:numeral) ==# 1
        return eval(a:numeral)
    endif

    let l:numerals = split(a:numeral, '\zs')

    let l:integer = 0
    for numeral in l:numerals
        if exists('l:prev_numeral')
            if l:prev_numeral ==? 'X' || l:prev_numeral ==? 'I'
                if eval(numeral) <= eval(l:prev_numeral)
                    let l:integer += eval(numeral)
                else
                    let l:integer -= eval(l:prev_numeral)
                    let l:integer += eval(numeral) - eval(l:prev_numeral)
                endif
                let l:prev_numeral = numeral
                continue
            endif
        endif

        let l:integer += eval(numeral)
        let l:prev_numeral = numeral
    endfor

    return l:integer
endfunction
" }}}2

" }}}1
