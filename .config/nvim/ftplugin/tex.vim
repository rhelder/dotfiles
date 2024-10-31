let g:enumerate_enabled = 0
setlocal formatoptions+=orl
setlocal formatoptions-=t
setlocal linebreak
setlocal nosmartindent

nnoremap <LocalLeader>gk /\v(\\textgreek\{)@<!<[Α-ῳἈ-ᾡΆ-ῷ]+>(\})@!<CR>
nnoremap <LocalLeader>tt <Cmd>call <SID>insert_maketitle_def()<CR>

" VimTeX configuration {{{1

let g:vimtex_complete_close_braces = 1
let g:vimtex_view_method = 'skim'
let g:vimtex_view_skim_reading_bar = 1
let g:vimtex_doc_handlers = ['vimtex#doc#handlers#texdoc']

let g:vimtex_complete_bib = {
      \ 'simple': 1,
      \ 'custom_patterns': ['sectioncite'],
      \ }

let g:vimtex_indent_delims = {
      \ 'open' : ['{','['],
      \ 'close' : ['}',']'],
      \ 'close_indented' : 0,
      \ 'include_modified_math' : 1,
      \ }

let g:vimtex_indent_conditionals = {
      \ 'open': '\v%(\\newif)@<!' ..
      \   '\\if%(f>|field|name|numequal|thenelse|' ..
      \   'toggle|bool|blank)@!',
      \ 'else': '\\else\>',
      \ 'close': '\\fi\>',
      \ }

let g:vimtex_indent_lists = [
      \ 'itemize',
      \ 'description',
      \ 'enumerate',
      \ 'thebibliography',
      \ 'trivlist',
      \ 'outline',
      \ 'displayquote',
      \ 'education',
      \ 'research',
      \ 'papers',
      \ 'talks',
      \ 'awards',
      \ 'service',
      \ ]

" Filter undesidered errors and warnings {{{2
let g:vimtex_quickfix_ignore_filters = []

nnoremap <LocalLeader>lf
      \ <Cmd>call <SID>toggle_vimtex_quickfix_ignore_filters()<CR>

function! s:toggle_vimtex_quickfix_ignore_filters() abort
  if empty(g:vimtex_quickfix_ignore_filters)
    let g:vimtex_quickfix_ignore_filters = ['Overfull \\hbox']
  else
    let g:vimtex_quickfix_ignore_filters = []
  endif
endfunction

" Make Vim regain focus after inverse search {{{2
" (from https://www.ejmastnak.com/tutorials/vim-latex/pdf-reader/
" #refocus-vim-after-forward-search)
augroup vimtex
  autocmd!
  autocmd User VimtexEventViewReverse call s:nvim_regain_focus()
augroup END

function! s:nvim_regain_focus() abort
  silent execute "!open -a kitty"
  redraw
endfunction

" ncm2 configuration {{{2
augroup ncm2_vimtex
  autocmd!
  autocmd BufEnter * call ncm2#enable_for_buffer()
  autocmd User Ncm2Plugin call ncm2#register_source({
        \ 'name': 'vimtex',
        \ 'priority': 8,
        \ 'scope': ['tex'],
        \ 'mark': 'tex',
        \ 'word_pattern': '\w+',
        \ 'complete_pattern': g:vimtex#re#ncm2,
        \ 'on_complete': ['ncm2#on_complete#omni',
        \   'vimtex#complete#omnifunc'],
        \ })
augroup END

"}}}2

" }}}1
