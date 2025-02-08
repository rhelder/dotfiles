if exists('g:loaded_jobs') | finish | endif
let g:loaded_jobs = 1

highlight default link JobInfo Question
highlight default link JobWarning WarningMsg
highlight default link JobError Error
highlight default link JobMsg ModeMsg
