if exists('b:did_ftplugin_mdnotes')
    finish
endif
let b:did_ftplugin_mdview = 1

if expand('%:p') !~# '/Users/rhelder/Documents/Notes/.*\.md'
    finish
endif

setlocal completefunc=s:mdcomplete_completefunc

nnoremap <buffer> <LocalLeader>nl
            \ <Cmd>call <SID>make_bracketed_list_hyphenated()<CR>

augroup mdnotes
    " Run MdviewConvert and build-index when exiting a note, if it has been
    " modified
    autocmd BufWinLeave <buffer> call s:exit_note()
    autocmd BufReadPost,BufNewFile <buffer>
                \ autocmd BufModifiedSet <buffer> ++once
                              \ let b:modified = 1

    " Set flag so that s:run_build_index can force 'hit enter' prompt before
    " quitting
    autocmd ExitPre <buffer> let s:exiting = 1
augroup END


function! s:mdcomplete_completefunc(findstart, base) abort " {{{1
    return mdcomplete#omnifunc(a:findstart, a:base, s:completers)
endfunction

let s:completer_keywords = {
            \ 'patterns': [
            \     {'detect': '\v^\s*keywords:\s+\[=([^,]*,\s+)*',
            \         'terminate': '\v^\s*keywords:\s+\[=([^,]*,\s+)*$'},
            \     {'detect': '\v^\s*-\s+', 'terminate': '\v^\s*-\s+$'},
            \ ],
            \ }

function! s:completer_keywords.in_context() abort dict " {{{2
    if !s:in_yaml_block() | return 0 | endif

    let l:key_line_number = search(s:yaml_key_regex, 'bnW')
    if !l:key_line_number | return 0 | endif
    let l:key_line = getline(l:key_line_number)
    if matchstr(l:key_line, s:yaml_key_regex) !=# 'keywords'
        return 0
    endif

    let l:pos = col('.') - 1
    let l:line = getline('.')[:l:pos-1]
    for pattern in self.patterns
        if l:pos > 0 && l:line =~# pattern.detect
            return 1
        endif
    endfor
    return 0
endfunction

function! s:in_yaml_block() abort " {{{3
    let l:start = search('\v^---\s*$', 'bnW')
    if !l:start | return 0 | endif

    let l:end = search('\v^(---|\.\.\.)\s*$', 'nW')
    if !l:end | return 0 | endif

    if getline(l:start + 1) =~# '\v^\s*$' ||
                \ (l:start != 1 && getline(l:start - 1) !~# '\v^\s*$')
        return 0
    endif

    if line('.') > l:start && line('.') < l:end
        return 1
    else
        return 0
    endif
endfunction

let s:yaml_key_start_chars = '[^\-?:,[\]{}#&*!|>''"%@`[:space:]]'
let s:yaml_key_can_start_if_chars = '[?:\-]([^[:space:]])@='
let s:yaml_key_subsequent_chars = '(\S#|:\S|[^[:space:]:#])*'
let s:yaml_key_chars = '(' .. s:yaml_key_start_chars .. '|' ..
            \ s:yaml_key_can_start_if_chars .. ')' ..
            \ s:yaml_key_subsequent_chars
let s:yaml_key_regex = '\v^\s*\zs' .. s:yaml_key_chars ..
            \ '(\s+' .. s:yaml_key_chars .. ')*\ze\s*:(\s|$)'
" }}}3

function! s:completer_keywords.complete(base) abort dict " {{{2
    if a:base[0:1] == '\@'
        let l:biblatex_keys = s:citation_completer.complete(a:base[2:])
        call map(l:biblatex_keys, '{"word": "\\@" .. v:val, "abbr": v:val}')
        return l:biblatex_keys

    else
        let l:name = $HOME .. '/Documents/Notes/index.txt'
        let l:keywords = readfile(l:name)
        call filter(l:keywords, 'v:val !~# "^@"')
        call filter(l:keywords, 'v:val =~? "^" .. a:base')
        return l:keywords
    endif
endfunction
" }}}2

let s:citation_completer = mdcomplete#completer_citations

let s:completers = [s:completer_keywords, s:citation_completer]

function! s:make_bracketed_list_hyphenated() abort " {{{1
    let l:unnamed_register = @"
    normal! ""di[
    let l:string = substitute(@", '\n', ' ', 'g')
    let l:list = split(l:string, ', ')
    call setline('.', substitute(getline('.'), '\(.*:\).*', '\1', ''))
    execute "normal o\<C-I>- " .. l:list[0] .. "\<Esc>"
    for item in l:list[1:-1]
        execute "normal! o- " .. item .. "\<Esc>"
    endfor
    let @" = l:unnamed_register
endfunction

function! s:exit_note() abort " {{{1
    " Use <afile> instead of %, and getbufvar with <afile> and 'modified'
    " instead of b:modified, because the latter will be wrong in some cases
    " when executing a BufWinleave autocommand (e.g., as when exiting Vim with
    " multiple windows open)
    if !filereadable(expand('<afile>')) ||
                \ !getbufvar(expand('<afile>'), 'modified', 0)
        return
    endif

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

    try
        execute s:run_build_index()
    catch /^Vim(echoerr):/
        echohl ErrorMsg
        for line in split(v:errmsg, '\n')
            echomsg line
        endfor
        echohl None
        if exists('s:exiting')
            echohl Type
            call input("\nPress ENTER or type command to continue")
            echohl None
        endif
    catch /build-index(stderr)/
        if exists('s:exiting')
            echohl Type
            call input("\nPress ENTER or type command to continue")
            echohl None
        endif
    endtry
endfunction

function! s:run_build_index() abort " {{{2
    echo 'Running build-index...'

    let l:filtered_stderr = system('build-index')
    if len(l:filtered_stderr) > 0
        let l:stderr = split(l:filtered_stderr, '\n')
        if v:shell_error == 0
            return 'echohl WarningMsg | for line in ' .. string(l:stderr) ..
                        \ ' | echomsg line | endfor | echohl None | ' ..
                        \ 'throw "build-index(stderr)"'
        else
            return 'let v:errmsg = join(' .. string(l:stderr) .. ', "\n") | ' ..
                        \ 'for line in ' .. string(l:stderr) ..
                        \ ' | echoerr line | endfor'
        endif
    else
        return ''
    endif
    return ''
endfunction
" }}}2

" }}}1

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

" mdView configuration " {{{1

function! s:mdview_output_file() abort dict
    " If the input file is an index file, manipulate the filename so that the
    " html filename is exactly equivalent to the corresponding keyword, so that
    " it can be linked to in a Pandoc template
    let l:input_file = self.input()
    if match(l:input_file, '_') == 0
        let l:file = substitute(l:input_file, '_', '@', '')
    else
        let l:file = l:input_file
    endif
    let l:file = substitute(l:file, '_', ' ', 'g')
    let l:file = substitute(l:file, '.md$', '.html', '')
    return l:file
endfunction

let g:mdview = {}
let g:mdview.output = function('s:mdview_output_file')
let g:mdview.pandoc_args = [
            \ '--defaults=notes',
            \ ]

" }}}1
