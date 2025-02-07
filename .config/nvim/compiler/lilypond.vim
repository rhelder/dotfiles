" [TODO]
" * Write Applescript to open Skim without refocusing

if exists('current_compiler') | finish | endif
let current_compiler = 'lilypond'

" 'errorformat' written by Heikki Junes and distributed with LilyPond
setlocal errorformat=%f:%l:%c:\ %m,%f:%l:\ %m,
setlocal errorformat+=In\ file\ included\ from\ %f:%l:,
setlocal errorformat+=\^I\^Ifrom\ %f:%l%m
silent CompilerSet errorformat

function! s:on_exit(job, status, event) abort dict
  call self.quickfix_on_exit(a:job, a:status, a:event)
  call self.notify_on_exit(a:job, a:status, a:event)
  if a:status | return | endif

  call shell#jobstart([
        \ 'open',
        \ '-a',
        \ 'Skim',
        \ expand('%<') .. '.pdf'
        \ ], {
        \ 'on_start': '',
        \ 'on_exit': '',
        \ })
endfunction

command! -buffer LilypondCompile call shell#jobstart([
      \ 'lilypond',
      \ '--output=' .. expand('%<'),
      \ expand('%'),
      \ ], {
      \ 'name': 'LilyPond',
      \ 'qflist': {'title': 'LilyPond'},
      \ 'on_exit': function('s:on_exit'),
      \ })
