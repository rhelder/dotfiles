if exists('b:did_ftplugin') | finish | endif

let g:markdown_recommended_style = 0
let g:markdown_folding = 1

source $VIMRUNTIME/ftplugin/markdown.vim

let &l:formatlistpat ..= '\|^\s*:\s\+\|^\s*\a\.\s\+'

let b:default_omnifunc = &omnifunc
let b:undo_ftplugin ..= '| unlet b:default_omnifunc'

let b:did_ftplugin = 1

setlocal nonumber
setlocal formatoptions-=l
setlocal textwidth=78
setlocal softtabstop=4
setlocal shiftwidth=4

command! -buffer -bang -nargs=?
      \ Pandoc call markdown#pandoc('<args>', '<bang>')

nmap <buffer> mm <Plug>(pandoc-compile)
nmap <buffer> <script> <Plug>(pandoc-compile) <SID>(pandoc-compile)
nnoremap <buffer> <SID>(pandoc-compile) <Cmd>Pandoc! -dhtml<CR>

setlocal omnifunc=markdown#omnifunc

augroup ncm2_markdown
  autocmd!
  autocmd BufEnter * call ncm2#enable_for_buffer()
  autocmd User Ncm2Plugin call ncm2#register_source({
        \ 'name': 'markdown',
        \ 'priority': 8,
        \ 'scope': ['markdown'],
        \ 'on_complete': ['ncm2#on_complete#omni', 'markdown#omnifunc'],
        \ 'word_pattern': '\w+',
        \ 'complete_length': -1,
        \ 'complete_pattern': ['(^|\[|\s)@\{?'],
        \ 'matcher': {'name': 'prefix', 'key': 'word'},
        \ 'sorter': 'none',
        \ })
augroup END
