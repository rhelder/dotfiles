function! notes#link#follow_link_map(action, filetype, lhs) abort " {{{1
    if !notes#link#follow_link(a:action, a:filetype)
        execute 'normal! ' .. a:lhs
    endif
endfunction

function! notes#link#follow_link(action, filetype) abort " {{{1
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
    return notes#link#u#in_keywords()
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
    if !notes#link#u#in_keywords()
        return 1
    else
        return 0
    endif
endfunction
" }}}2

" }}}1

let s:link_handlers = [
            \ s:ref_link_handler,
            \ s:citation_link_handler,
            \ s:keyword_link_handler,
            \ ]
