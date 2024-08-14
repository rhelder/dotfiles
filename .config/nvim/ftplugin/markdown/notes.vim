if exists('b:did_ftplugin_notes') | finish | endif
let b:did_ftplugin_notes = 1

if expand('%:p:h') !=# '/Users/rhelder/Documents/Notes'
    finish
endif

call notes#init_buffer()
