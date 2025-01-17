setlocal formatoptions+=orl
setlocal formatoptions-=t

" VimTeX configuration {{{1

let g:vimtex_complete_close_braces = 1
let g:vimtex_view_method = 'skim'
let g:vimtex_view_skim_reading_bar = 1
let g:vimtex_doc_handlers = ['vimtex#doc#handlers#texdoc']

" Folding {{{2

let g:vimtex_fold_enabled = 1
let g:vimtex_fold_manual = 1

let g:vimtex_fold_types = {
      \ 'items': {'enabled': 0},
      \ 'envs': {'enabled': 0},
      \ 'env_options': {'enabled': 0},
      \ 'cmd_single': {'enabled': 0},
      \ 'cmd_single_opt': {'enabled': 0},
      \ 'cmd_multi': {'enabled': 0},
      \ 'markers': {},
      \ 'sections': {},
      \ }

function! g:vimtex_fold_types.markers.text(line, level) abort dict
  return foldtext()
endfunction

let g:vimtex_fold_types.sections.defaulttext =
      \ vimtex#fold#sections#new({}).text
function! g:vimtex_fold_types.sections.text(line, level) abort dict
  if a:line =~# self.re.fake_sections
    let l:title = matchstr(a:line, self.re.fake_sections)
    let l:title = substitute(l:title, '% Fake\S* ', '', '')

    let l:level = self.parse_level(v:foldstart, a:level)

    return printf('%-5s %-s', l:level,
          \ substitute(strpart(l:title, 0, winwidth(0) - 7), '\s\+$', '', ''))
  endif

  return self.defaulttext(a:line, a:level)
endfunction

" Indentation {{{2

let g:vimtex_indent_delims = {
      \ 'open' : ['{','['],
      \ 'close' : ['}',']'],
      \ 'close_indented' : 0,
      \ 'include_modified_math' : 1,
      \ }

let g:vimtex_indent_conditionals = {
      \ 'open': '\v\c%(\\newif)@<!' ..
      \   '\\if%(f>|thenelse>|value|packageloaded|' ..
      \   'bool|toggle>|(un)?def|cs|ltxcounter>|str|blank|' ..
      \   'num\a+>|dim\a+>|' ..
      \   '(end)?date|label|case|sort(ing|alpha)|unique|' ..
      \   '(current)?(name|field|list)|use|(cross|x)refsource>|' ..
      \   'singletitle>|nocite>|andothers>|more|.*inits>|' ..
      \   'keyword>|entry|category>|(first|last|vol)?cite|(op|loc)cit>|' ..
      \   '.*pages?>|integer>|iscomputable>|field|' ..
      \   '(nat)?bib|driver>|capital>|citation>|biliography>|footnote>)@!',
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

" dtx configuration {{{1

if expand('%:e') !=# 'dtx' | finish | endif

nnoremap <buffer> <LocalLeader>ld <Cmd>call <SID>dtx_toggle_comments()<CR>
nnoremap <buffer> <LocalLeader>lD <Cmd>call <SID>dtx_toggle_opts()<CR>

augroup vimtex_dtx
  autocmd!
  autocmd BufWritePre <buffer> call s:dtx_on_write()
augroup END

function s:dtx_on_write() abort
  if get(s:dtx_comment_toggler, 'mode', 0)
    call s:dtx_toggle_comments()
    autocmd BufWritePost <buffer> ++once call s:dtx_toggle_comments()
  endif
endfunction

function s:dtx_toggle_comments() abort
  call s:dtx_comment_toggler.init()
  call s:dtx_comment_toggler.toggle()
endfunction

function s:dtx_toggle_opts() abort
  call s:dtx_comment_toggler.init()
endfunction

let s:dtx_comment_toggler = {
      \ 'comment': '\v^\%',
      \ 'guards': ['driver', 'package'],
      \ 'envs': ['macrocode', 'noprintcode'],
      \ 'opts': {
      \   'foldmethod': 'manual',
      \   'varsofttabstop': '1,3,2',
      \   },
      \ 'formatoptions': {'+': [], '-': ['r', 'o']},
      \ }

function! s:dtx_comment_toggler.init() dict abort
  let l:current_opts = {}

  for [l:key, l:value] in items(self.opts)
    execute 'let l:current_opts.' .. l:key .. ' = ' .. '&' .. l:key
    execute 'set ' .. l:key .. '=' .. l:value
  endfor

  if empty(get(self.opts, 'formatoptions', ''))
    let l:current_opts.formatoptions = &formatoptions
    for [l:key, l:value] in items(self.formatoptions)
      for l:opt in l:value
        execute 'set formatoptions' .. l:key .. '=' .. l:opt
      endfor
    endfor
  endif

  let self.opts = l:current_opts

  let self.mode = get(self, 'mode', 0)
        \ ? 0
        \ : 1
endfunction

function! s:dtx_comment_toggler.toggle() dict abort
  let self.start_stop_pattern =
        \ '\v^%(\%\<(.?)%(' .. join(self.guards, '|') .. ')'
        \ .. '|\%?    \\(begin|end)\{%(' .. join(self.envs, '|') .. ')})'
  let l:pos = getcurpos()
  let self.notoggle = 0

  for l:lnum in range(1, line('$'))
    let l:line = getline(l:lnum)
    if self.is_notoggle(l:line) | continue | endif

    call setline(l:lnum,
          \ l:line =~# self.comment
          \   ? substitute(l:line, self.comment, '', '')
          \   : '%' .. l:line
          \ )
  endfor

  silent %substitute/\v^(\%)?\s?$/\1/e
  call setpos('.', l:pos)
endfunction

function! s:dtx_comment_toggler.is_notoggle(line) dict abort
  let l:matchlist = matchlist(a:line, self.start_stop_pattern)
  if empty(l:matchlist) | return self.notoggle | endif

  if l:matchlist[1] ==# '*' || l:matchlist[2] ==# 'begin'
    let self.notoggle += 1
    return l:matchlist[2] ==# 'begin' && self.notoggle ==# 1
          \ ? 0
          \ : self.notoggle

  elseif l:matchlist[1] ==# '/' || l:matchlist[2] == 'end'
    let self.notoggle = 0
    return 1
  endif
endfunction

" }}}1
