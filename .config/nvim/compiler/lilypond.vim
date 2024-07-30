" [TODO]
" * Write Applescript to open Skim without refocusing

if exists('current_compiler') | finish | endif
let current_compiler = 'lilypond'

" 'errorformat' written by Heikki Junes and distributed with LilyPond
setlocal errorformat=%f:%l:%c:\ %m,%f:%l:\ %m,
setlocal errorformat+=In\ file\ included\ from\ %f:%l:,
setlocal errorformat+=\^I\^Ifrom\ %f:%l%m
silent CompilerSet errorformat

function! s:open_output(job_id, exit_code, event) abort dict
    if a:event !=# 'exit' | return | endif

    call self.createqflist(a:job_id, a:exit_code, a:event)

    if !a:exit_code
        call shell#jobstart(['open', '-a', 'Skim', expand('%<') .. '.pdf'], {})
    endif
endfunction

command! -buffer LilypondCompile
            \ call shell#compile([
            \   'lilypond',
            \   '--output=' .. expand('%<'),
            \   expand('%')
            \ ], {
            \   'msg': 3,
            \   'qf': {'window': 1, 'title': 'LilyPond'},
            \   'callback': function('s:open_output'),
            \ })
