augroup lilypond
    autocmd!
    autocmd BufNewFile *.ly call append(0, '\version "2.24.3"')
augroup END
