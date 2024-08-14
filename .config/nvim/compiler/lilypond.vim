" [TODO]
" * Write Applescript to open Skim without refocusing

if exists('current_compiler') | finish | endif
let current_compiler = 'lilypond'

" 'errorformat' written by Heikki Junes and distributed with LilyPond
setlocal errorformat=%f:%l:%c:\ %m,%f:%l:\ %m,
setlocal errorformat+=In\ file\ included\ from\ %f:%l:,
setlocal errorformat+=\^I\^Ifrom\ %f:%l%m
silent CompilerSet errorformat

function! s:open_output(job, status, event) abort dict
    if a:event !=# 'exit' | return | endif
    if a:status | return | endif

    call shell#jobstart(['open', '-a', 'Skim', expand('%<') .. '.pdf'], {})
endfunction

command! -buffer LilypondCompile
            \ call shell#compile([
            \   'lilypond',
            \   '--output=' .. expand('%<'),
            \   expand('%'),
            \ ], {
            \   'qf_win': {'title': 'LilyPond'},
            \   'callback': function('s:open_output'),
            \ })
