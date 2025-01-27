if exists('b:did_ftplugin_markdown') | finish | endif
let b:did_ftplugin_markdown = 1

let g:pandoc#formatting#mode = 'h'
let g:pandoc#formatting#textwidth = 78
let g:pandoc#syntax#conceal#use = 0
let g:pandoc#biblio#sources = 'g'
let g:pandoc#biblio#bibs = ['/Users/rhelder/.local/share/pandoc/my_library.json']

augroup ncm2_markdown
  autocmd!
  autocmd BufEnter * call ncm2#enable_for_buffer()
  autocmd User Ncm2Plugin call ncm2#register_source({
        \ 'name': 'pandoc',
        \ 'priority': 8,
        \ 'scope': ['pandoc'],
        \ 'matcher': {'name': 'prefix', 'key': 'word'},
        \ 'sorter': 'none',
        \ 'word_pattern': '\w+',
        \ 'complete_pattern': ['(?<!\\)@'],
        \ 'complete_length': -1,
        \ 'on_complete': ['ncm2#on_complete#omni',
        \     'pandoc#completion#Complete'],
        \ })
augroup END
        " \ 'complete_pattern': ['(\\)@<!\@'],
