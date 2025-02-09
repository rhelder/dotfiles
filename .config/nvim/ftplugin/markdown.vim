if exists('b:did_ftplugin') | finish | endif

let g:pandoc#modules#enabled = ['folding']
let g:pandoc#folding#fdc = 0
let g:pandoc#folding#fastfolds = 1
let g:pandoc#syntax#conceal#use = 0
source $XDG_DATA_HOME/nvim/plugged/vim-pandoc/ftplugin/pandoc.vim

let b:did_ftplugin = 1

command! -buffer -bang -nargs=?
      \ -complete=customlist,pandoc#command#PandocComplete
      \ Pandoc call markdown#pandoc('<args>', '<bang>')

augroup ncm2_markdown
  autocmd!
  autocmd BufEnter * call ncm2#enable_for_buffer()
  autocmd User Ncm2Plugin call ncm2#register_source({
        \ 'name': 'markdown',
        \ 'priority': 8,
        \ 'scope': ['markdown'],
        \ 'matcher': {'name': 'prefix', 'key': 'word'},
        \ 'sorter': 'none',
        \ 'word_pattern': '\w+',
        \ 'complete_pattern': ['(?<!\\)@'],
        \ 'complete_length': -1,
        \ 'on_complete': ['ncm2#on_complete#omni',
        \     'pandoc#completion#Complete'],
        \ })
augroup END
