" Global

function! notes#new_note() abort " {{{1
    lcd ~/Documents/Notes
    let l:name = strftime("%Y%m%d%H%M%S")
    execute 'edit ' .. l:name .. '.md'
    execute "normal i---\r---\<Esc>"
    execute "normal Okeywords: \<Esc>"
    execute "normal Otitle: \<Esc>"
    execute 'normal Oid: ' .. l:name .. "\<Esc>"
endfunction

function! notes#new_journal() abort " {{{1
    lcd $HOME/Documents/Notes
    execute 'edit ' .. strftime('%F') .. '.txt'
    if !filereadable(strftime('%F') .. '.txt')
        execute 'normal i' .. strftime('%A, %B %e, %Y') .. "\<Esc>"
        execute "normal 2o\<Esc>"
    endif
endfunction

function! notes#search_notes() abort " {{{1
    lcd $HOME/Documents/Notes
    Rfv [[:digit:]]*.md
endfunction

function! notes#browse_index() abort " {{{1
    let l:browse_index_spec = {
                \ 'dir': "$HOME/Documents/Notes",
                \ 'source': 'fd "[A-z].*\.md"',
                \ 'left': '50',
                \ 'options': s:fzf_expect(),
                \ 'sinklist': function('s:browse_index_open_result'),
                \ }

    return l:browse_index_spec
endfunction

function! notes#fzf_expect() abort " {{{2
    let l:options = []

    for key in keys(s:browse_index_action)
        let l:option = '--expect=' .. key
        call add(l:options, l:option)
    endfor

    return l:options
endfunction

let s:browse_index_action = {
            \ 'ctrl-v': 'vertical split',
            \ 'ctrl-x': 'split',
            \ 'ctrl-o': 'silent !md-open',
            \ }

function! notes#browse_index_open_result(lines) abort " {{{2
    if len(a:lines) < 2
        return
    endif

    let l:key = a:lines[0]
    let l:result = a:lines[1]

    if type(get(s:browse_index_action, l:key, 'edit')) == v:t_func
        call s:browse_index_action[l:key](l:result)
    else
        execute get(s:browse_index_action, l:key, 'edit') l:result
    endif
endfunction
" }}}2

" }}}1

" Filetype

" Completion {{{1

function! notes#completefunc(findstart, base) abort
    return mdcomplete#omnifunc(a:findstart, a:base, s:completers)
endfunction

" Keyword completer {{{2

let notes#completer_keywords = {
            \ 'patterns': [
            \     {'detect': '\v^\s*keywords:\s+\[=([^,]*,\s+)*',
            \         'terminate': '\v^\s*keywords:\s+\[=([^,]*,\s+)*$'},
            \     {'detect': '\v^\s*-\s+', 'terminate': '\v^\s*-\s+$'},
            \ ],
            \ }

function! notes#completer_keywords.in_context() abort dict " {{{3
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

function! s:in_yaml_block() abort " {{{4
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
" }}}4

function! notes#completer_keywords.complete(base) abort dict " {{{3
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
" }}}3

" }}}2

let s:citation_completer = mdcomplete#completer_citations
let s:completers = [notes#completer_keywords, s:citation_completer]

" }}}1

function! notes#make_bracketed_list_hyphenated() abort " {{{1
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

function! notes#exit_note() abort " {{{1
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
        execute mdview#convert_to_html()

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
        if exists('b:exiting')
            echohl Type
            call input("\nPress ENTER or type command to continue")
            echohl None
        endif
    catch /build-index(stderr)/
        if exists('b:exiting')
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

function! notes#insert_link(file) abort " {{{1
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

function! notes#mdview_output_file() abort dict " {{{1
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

" }}}1
