" Completion

function! notes#omnifunc(findstart, base, completers=[]) abort " {{{1
    if empty(a:completers)
        call extend(a:completers, s:omnifunc_completers)
    endif

    if a:findstart
        if exists('s:completer') | unlet s:completer | endif

        " Subtract by one to align with index of l:line
        let l:start = col('.') - 1
        " Set l:line equal to the portion of the line behind the cursor
        let l:line = getline('.')[:l:start-1]

        for completer in a:completers
            if completer.in_context()
                if has_key(completer, 'find_start')
                    let s:completer = completer
                    return s:completer.find_start()
                endif

                for pattern in completer.patterns
                    if l:line =~# pattern.detect
                        let s:completer = completer
                        while l:start > 0
                            if l:line[:l:start-1] =~# pattern.terminate
                                return l:start
                            else
                                let l:start -=1
                            endif
                        endwhile
                    endif
                endfor
            endif
        endfor
        return -3
    elseif !exists('s:completer')
        " Ordinarily, if s:completer is not defined, completion is cancelled,
        " the function is not called again with findstart=0, and so
        " s:completer.complete is not called; so there's no error that
        " s:completer is undefined. But a wrapper function (such as when you're
        " using an autocomplete plugin) might call the function with
        " findstart=0 regardless. To avoid an error, return an empty list if
        " s:completer is undefined.
        return []
    else
        return s:completer.complete(a:base)
    endif
endfunction

function! notes#completefunc(findstart, base) abort " {{{1
    return notes#omnifunc(a:findstart, a:base, s:completefunc_completers)
endfunction

" Citation completer {{{1

let s:completer_citations = {
            \ 'patterns': [
            \     {'detect': '\v(^|\[|\s)\@[0-9A-Za-z._-]*$',
            \         'terminate': '\v(^|\[|\s)\@$'},
            \ ],
            \ }

function! s:completer_citations.in_context() abort dict " {{{2
    let l:pos = col('.') - 1
    let l:line = getline('.')[:l:pos-1]
    for pattern in self.patterns
        if l:pos > 0 && l:line[:l:pos-1] =~# pattern.detect
            return 1
        endif
    endfor
    return 0
endfunction

function! s:completer_citations.complete(base) abort dict " {{{2
    let l:biblatex_file_path =
                \ $HOME .. '/Library/texmf/bibtex/bib/my_library.bib'
    let l:biblatex_file = readfile(l:biblatex_file_path)
    call filter(l:biblatex_file, 'v:val[0] ==# "@"')
    let l:biblatex_keys = map(l:biblatex_file, function('s:biblatex_trim'))
    call filter(l:biblatex_keys, 'v:val =~# "^" .. a:base')
    return l:biblatex_keys
endfunction

function! s:biblatex_trim(index, val) abort " {{{3
    return substitute(a:val, '\v^\@.+\{(.+),$', '\1', '')
endfunction
" }}}3
" }}}2

" Default completer {{{1

let s:completer_default = {}

function! s:completer_default.in_context() abort
    return 1
endfunction

function! s:completer_default.find_start() abort
    return function(b:default_omnifunc)(1, '')
endfunction

function! s:completer_default.complete(base) abort
    return function(b:default_omnifunc)(0, a:base)
endfunction

" Keyword completer {{{1

let s:completer_keywords = {
            \ 'patterns': [
            \     {'detect': '\v^\s*keywords\s*:\s+\[=([^,]*,\s+)*',
            \         'terminate': '\v^\s*keywords:\s+\[=([^,]*,\s+)*$'},
            \     {'detect': '\v^\s*-\s+', 'terminate': '\v^\s*-\s+$'},
            \ ],
            \ }

function! s:completer_keywords.in_context() abort dict " {{{2
    return s:_in_keywords()
endfunction

function! s:completer_keywords.complete(base) abort dict " {{{2
    if a:base[0:1] == '\@'
        let l:biblatex_keys = s:completer_citations.complete(a:base[2:])
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

" }}}1

let s:omnifunc_completers = [
            \ s:completer_citations,
            \ s:completer_default,
            \ ]

let s:completefunc_completers = [
            \ s:completer_keywords,
            \ s:completer_citations,
            \ ]

" Links

function! notes#follow_link_map(action, filetype, lhs) abort " {{{1
    if !notes#follow_link(a:action, a:filetype)
        execute 'normal! ' .. a:lhs
    endif
endfunction

function! notes#follow_link(action, filetype) abort " {{{1
    for handler in s:link_handlers
        call handler.create_url(a:filetype)
        if has_key(handler, 'url')
            call handler.follow_link(a:action)
            unlet handler.url
            return 1
        endif
    endfor
    return 0
endfunction

" Markdown reference links {{{1

let s:ref_link_handler = {}

function! s:ref_link_handler.follow_link(action) abort dict " {{{2
    if filereadable(self.url)
        if match(a:action, '!')
            execute a:action .. ' ' .. self.url
        else
            execute 'silent ' a:action .. ' ' .. shellescape(self.url)
            redraw
        endif
    else
        echohl WarningMsg
        echomsg 'File not found at URL'
        echohl None
    endif
endfunction

function! s:ref_link_handler.create_url(filetype) abort dict " {{{2
    let l:url = self.get_text_under_cursor()
    if empty(l:url) | return | endif

    if a:filetype ==# 'html'
        if match(l:url, '_') == 0
            let l:url = substitute(l:url, '_', '@', '')
        endif
        let l:url = substitute(l:url, '_', ' ', 'g')
        let l:url = substitute(l:url, '.md$', '.html', '')
    endif
    let l:url = expand('%:p:h') .. '/' .. l:url
    let l:url = fnamemodify(l:url, ':.')
    let self.url = l:url
endfunction

function! s:ref_link_handler.get_text_under_cursor() abort dict " {{{2
    let l:syntax_group = self.in_context()
    if empty(l:syntax_group) | return '' | endif

    let l:pos = getcurpos()
    let l:unnamed_register = @"

    if l:syntax_group ==# 'markdownLinkTextDelimiter'
        execute "normal! vi[\<Esc>f[vi[\"\"y"
    elseif l:syntax_group ==# 'markdownIdDelimiter'
        normal! vi[""y
    endif

    let l:text = @"

    let @" = l:unnamed_register
    call setpos('.', l:pos)

    return l:text
endfunction

function! s:ref_link_handler.in_context() abort dict " {{{2
    let l:pos = getcurpos()
    if search('\[', 'bcW')
        normal! %
        let l:syntax_group = synIDattr(synID(line('.'), col('.'), 0), 'name')
        if (l:pos[1] < line('.') ||
                    \ (l:pos[1] == line('.') && l:pos[2] <= col('.'))) &&
                    \ (l:syntax_group ==# 'markdownIdDelimiter' ||
                    \ l:syntax_group ==# 'markdownLinkTextDelimiter')
            call setpos('.', l:pos)
            return l:syntax_group
        else
            call setpos('.', l:pos)
            return ''
        endif
    else
        return ''
    endif
endfunction
" }}}2

" Keyword links {{{1

let s:keyword_link_handler = {
            \ 'patterns': [
            \     {'start': '\v(^\s*keywords\s*:\s+[?\S|,\s+\S)',
            \         'end': '\v\s*(,|]|$)'},
            \     {'start': '\v^\s*-\s+\S', 'end': '\v\s*$'},
            \ ],
            \ }

function! s:keyword_link_handler.follow_link(action) abort dict " {{{2
    if filereadable(self.url)
        if match(a:action, '!')
            execute a:action .. ' ' .. self.url
        else
            execute 'silent ' a:action .. ' ' .. shellescape(self.url)
            redraw
        endif
    else
        echohl WarningMsg
        echomsg 'File not found at URL'
        echohl None
    endif
endfunction

function! s:keyword_link_handler.create_url(filetype) abort dict " {{{2
    let l:keyword = self.get_text_under_cursor()
    if empty(l:keyword) | return | endif

    if a:filetype ==# 'markdown'
        let l:url = l:keyword .. '_index.md'
        if match(l:keyword, '\\@') == 0
            let l:url = substitute(l:url, '\\@', '_', '')
        endif
        let l:url = substitute(l:url, ' ', '_', 'g')
    elseif a:filetype ==# 'html'
        let l:url = l:keyword .. ' index.html'
        if match(l:url, '\\@') == 0
            let l:url = substitute(l:keyword, '\\@', '@', '')
        endif
    endif

    let l:url = expand('%:p:h') .. '/' .. l:url
    let l:url = fnamemodify(l:url, ':.')
    let self.url = l:url
endfunction

function! s:keyword_link_handler.get_text_under_cursor() abort dict " {{{2
    if !self.in_context() | return '' | endif
    let l:line_number = line('.')
    for pattern in self.patterns
        let l:start = searchpos(pattern.start, 'bcn', l:line_number)[1]
        if l:start
            let l:pattern = pattern
            break
        endif
    endfor

    let l:start_end = searchpos(l:pattern.start, 'bcne', l:line_number)[1]
    let l:pos = col('.')
    if l:start_end < l:start && l:start_end < l:pos
        return ''
    endif

    let l:end = searchpos(pattern.end, 'cn', l:line_number)[1]
    if l:pos >= l:end
        return ''
    endif

    let l:text = getline('.')[l:start_end-1:l:end-2]
    return l:text
endfunction

function! s:keyword_link_handler.in_context() abort " {{{2
    return s:_in_keywords()
endfunction
" }}}2

" Citation links {{{1

let s:citation_link_handler = {
            \ 'chars': '0-9A-Za-z._-',
            \ 'pattern': '\v^\@[0-9A-Za-z._-]+$',
            \ }

function! s:citation_link_handler.follow_link(...) abort dict " {{{2
    if filereadable(self.url)
        execute 'silent !open ' .. self.url
        redraw
    else
        echohl WarningMsg
        echomsg 'No PDF found for this citation key'
        echohl None
    endif
endfunction

function! s:citation_link_handler.create_url(...) abort dict " {{{2
    let l:biblatex_key = substitute(self.get_text_under_cursor(), '^@', '', '')
    if empty(l:biblatex_key) | return '' | endif
    let l:dirname = substitute(l:biblatex_key, '\.$', '', '')
    let l:dir = $HOME .. '/Documents/Zotero/Storage' .. '/' .. l:dirname
    let l:url = l:dir .. '/' .. l:biblatex_key .. '.pdf'
    let self.url = l:url
endfunction

function! s:citation_link_handler.get_text_under_cursor() abort dict " {{{2
    if !self.in_context() | return '' | endif

    let l:text = expand('<cWORD>')
    let l:text = substitute(l:text, '^[^@' .. self.chars .. ']*', '', 'g')
    let l:text = substitute(l:text, '[^' .. self.chars .. ']*$', '', 'g')
    if l:text =~# self.pattern
        return l:text
    else
        return ''
    endif
endfunction

function! s:citation_link_handler.in_context() abort " {{{2
    if !s:_in_keywords()
        return 1
    else
        return 0
    endif
endfunction

" }}}1

let s:link_handlers = [
            \ s:ref_link_handler,
            \ s:citation_link_handler,
            \ s:keyword_link_handler,
            \ ]

" Utility functions

function! s:_in_keywords() abort " {{{1
    if !s:_in_yaml_block() | return 0 | endif

    let l:key_line_number = search(s:yaml_key_regex, 'bnW')
    if !l:key_line_number | return 0 | endif
    let l:key_line = getline(l:key_line_number)
    if matchstr(l:key_line, s:yaml_key_regex) ==# 'keywords'
        return 1
    else
        return 0
    endif
endfunction

function! s:_in_yaml_block() abort " {{{1
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

" }}}1

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

function! s:fzf_expect() abort " {{{2
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

function! s:browse_index_open_result(lines) abort " {{{2
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

" Notes only

function! notes#index_word_count() abort " {{{1
    let l:modified = getbufvar('%', 'modified', 0)
    let l:curpos = getcurpos()

    silent %sort u
    silent %g/^[^*].*$/delete
    silent %g/^$/delete
    nohlsearch

    let l:word_count = 0
    for line in range(1, line('$'))
        let l:pos = col('$') - 2
        call setpos('.', [0, line, l:pos, 0])
        let l:word_count += str2nr(system(['wc', '-w'],
                    \ system(['pandoc', '-t', 'plain', expand('<cfile>')])))
    endfor

    silent undo
    call setpos('.', l:curpos)
    if !l:modified
        augroup index_word_count
            autocmd!
            autocmd BufModifiedSet <buffer> ++once
                        \ call setbufvar(expand('<afile>'), 'modified', 0)
            autocmd BufModifiedSet <buffer> ++once
                        \ autocmd BufModifiedSet <buffer> ++once
                        \   call setbufvar(expand('<afile>'), 'modified', 1)
        augroup END
    endif

    echomsg l:word_count
endfunction

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

function! notes#exit_note(event) abort " {{{1
    " Use <afile> instead of %, and getbufvar with <afile> and 'modified'
    " instead of b:modified, because the latter will be wrong in some cases
    " when executing a BufWinleave autocommand (e.g., as when exiting Vim with
    " multiple windows open)
    if !filereadable(expand('<afile>')) ||
                \ !getbufvar(expand('<afile>'), 'modified', 0) ||
                \ (getbufvar(expand('<afile>'), 'exiting', 0) &&
                \   a:event ==# 'BufWinLeave')
        return
    endif

    echo 'Running MdviewConvert...'
    redraw
    if mdview#convert_to_html(v:false)
        echohl Type
        call input('Press ENTER or type command to continue')
        echohl None
        redraw
    endif

    echo 'Running build-index...'
    redraw
    if a:event == 'BufWinLeave'
        call shell#jobstart(['build-index'], s:build_index_background_opts)
    else
        if shell#jobstart(['build-index'], s:build_index_exiting_opts)
            echohl Type
            call input('Press ENTER or type command to continue')
            echohl None
        endif
    endif
endfunction

let s:build_index_background_opts = {
            \ 'detach': v:true,
            \ }
let s:build_index_exiting_opts = {
            \ 'sync': {'events': ['stderr']}
            \ }

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
    let l:input = self.input()
    let l:head = fnamemodify(l:input, ':h')
    let l:tail = fnamemodify(l:input, ':t')
    let l:tail = substitute(l:tail, '^_', '@', '')
    let l:tail = substitute(l:tail, '_', ' ', 'g')
    let l:tail = substitute(l:tail, '.md$', '.html', '')
    let l:output = l:head .. '/' .. l:tail
    return l:output
endfunction

" }}}1
