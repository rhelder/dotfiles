function! notes#fzf#search_notes() abort " {{{1
    lcd $HOME/Documents/Notes
    Rfv [[:digit:]]*.md
endfunction

function! notes#fzf#browse_notes(bang) abort " {{{1
    call fzf#toggle_vim_global_display_opts(a:bang)

    let l:fzf_options = fzf#opts_expect(s:fzf_action) + [
                \ '--ansi',
                \ '--multi',
                \ '--preview=bat --color=always {}',
                \ '--preview-window=~3,+3/2',
                \ ]

    let l:browse_notes_spec = {
                \ 'dir': "$HOME/Documents/Notes",
                \ 'source': 'fd "\d+\.md" | sort --ignore-case --reverse',
                \ 'options': l:fzf_options,
                \ 'sinklist': function('s:fzf_open_files'),
                \ }

    return l:browse_notes_spec
endfunction

function! notes#fzf#browse_index(bang) abort " {{{1
    call fzf#toggle_vim_global_display_opts(a:bang)
    augroup browse_index
        autocmd!
        autocmd FileType fzf setlocal statusline=%y\ Index\ files
    augroup END

    let l:browse_index_spec = {
                \ 'dir': "$HOME/Documents/Notes",
                \ 'source': 'fd "[A-Za-z_].*\.md" | sort --ignore-case',
                \ 'left': '50',
                \ 'options': ['--multi'] + fzf#opts_expect(s:fzf_action),
                \ 'sinklist': function('s:fzf_open_files'),
                \ }

    return l:browse_index_spec
endfunction

function! s:fzf_open_files(lines) abort
    call fzf#open_files(a:lines, s:fzf_action)
endfunction

function! notes#fzf#browse_links(bang) abort " {{{1
    call fzf#toggle_vim_global_display_opts(a:bang)

    let l:file_text = join(getline(1, '$'))
    let l:links = []
    let l:start = 0
    while 1
        let l:strpos = matchstrpos(l:file_text,
                    \ '\v\[[^][]*\]\[[^][]+\]', l:start)
        let l:link = matchlist(l:strpos[0], '\v\[([^][]*)\]\[([^][]+)\]')
        if !empty(l:link)
            call add(l:links, ['[38;5;121m' .. link[2],
                        \ '[4;38;5;81m' .. link[1] .. '[0m'])
            let l:start = l:strpos[2]
        else
            break
        endif
    endwhile

    call uniq(sort(l:links, function('s:fzf_sort_links')))
    call map(l:links, 'join(reverse(v:val), ":")')

    let l:fzf_options = fzf#opts_expect(s:fzf_action) + [
                \ '--ansi',
                \ '--multi',
                \ '--delimiter=:',
                \ '--preview=bat --color=always {-1}',
                \ '--preview-window=~3,+3/2',
                \ ]

    let l:browse_links_spec = {
                \ 'dir': "$HOME/Documents/Notes",
                \ 'source': l:links,
                \ 'options': l:fzf_options,
                \ 'sinklist': function('s:fzf_open_links'),
                \ }

    return l:browse_links_spec
endfunction

function! s:fzf_sort_links(first, second) abort " {{{2
    let l:start = 11
    if a:first ==? a:second
        return 0
    elseif a:first[0][l:start] =~ '\D' && a:second[0][l:start] =~ '\d'
        return 1
    elseif a:first[0][l:start] =~ '\d' && a:second[0][l:start] =~ '\D'
        return -1
    else
        let l:status = 0
        while l:status == 0
            let l:status = char2nr(tolower(a:second[0][l:start])) -
                        \ char2nr(tolower(a:first[0][l:start]))
            let l:start +=1
        endwhile
        return l:status
    endif
endfunction

function! s:fzf_open_links(lines) abort " {{{2
    call fzf#open_files(a:lines, s:fzf_action, function('s:fzf_get_urls'))
endfunction

function! s:fzf_get_urls(links) abort " {{{3
    let l:urls = []
    for link in a:links
        call add(l:urls, substitute(link, '\v.*:([^:])', '\1', ''))
    endfor
    return l:urls
endfunction
" }}}3
" }}}2

function! notes#fzf#insert_link(file) abort " {{{1
    execute 'normal! a[' .. a:file .. "]\<Esc>"
    let l:url = substitute(a:file, '.md$', '.html', '')
    let l:cursor_position = getpos('.')
    if getline('$') =~ '^\[.*\]: .*'
        execute 'normal! Go[' .. a:file .. ']: ' .. l:url .. "\<Esc>"
    else
        execute "normal! Go\<CR>\<Esc>i[" .. a:file .. ']: ' .. l:url ..
                    \ "\<Esc>"
    endif
    call setpos('.', l:cursor_position)
endfunction

" }}}1

let s:fzf_action = {
            \ 'ctrl-v': 'vertical split',
            \ 'ctrl-x': 'split',
            \ 'ctrl-o': 'silent !md-open',
            \ }

let g:rfv_action = {
            \ 'ctrl-v': 'vertical split',
            \ 'ctrl-x': 'split',
            \ 'ctrl-o': 'silent !md-open',
            \ 'ctrl-]': function('notes#fzf#insert_link'),
            \ }
