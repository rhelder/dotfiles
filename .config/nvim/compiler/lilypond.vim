if exists('current_compiler') | finish | endif
let current_compiler = 'lilypond'

" 'errorformat' written by Heikki Junes and distributed with LilyPond
setlocal errorformat=%f:%l:%c:\ %m,%f:%l:\ %m,
setlocal errorformat+=In\ file\ included\ from\ %f:%l:,
setlocal errorformat+=\^I\^Ifrom\ %f:%l%m
silent CompilerSet errorformat

function! s:callback(job_id, exit_status, event) abort
    if a:event !=# 'exit' | return | endif
    if a:exit_status ># 0 | return | endif

    call shell#jobstart(['open', expand('%<') .. '.pdf'], {})
endfunction

command! -buffer LilypondCompile
            \ call shell#jobstart([
            \   'lilypond',
            \   '--output=' .. expand('%<'),
            \   expand('%')
            \ ], {
            \   'msg': 1,
            \   'qf': 1,
            \   'qf_args': [1, 'LilyPond'],
            \   'callback': function('s:callback'),
            \ })
