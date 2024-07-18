if exists('current_compiler') | finish | endif
let current_compiler = 'lilypond'

" 'errorformat' written by Heikki Junes and distributed with LilyPond
setlocal errorformat=%f:%l:%c:\ %m,%f:%l:\ %m,
setlocal errorformat+=In\ file\ included\ from\ %f:%l:,
setlocal errorformat+=\^I\^Ifrom\ %f:%l%m
silent CompilerSet errorformat

command! -buffer LilypondCompile
            \ call shell#jobstart('lilypond ' .. expand('%'), {
            \   'cwd': expand('%:p:h'),
            \   'msg': 1,
            \   'qf': 1,
            \   'qf_args': [1, 'LilyPond'],
            \ })
