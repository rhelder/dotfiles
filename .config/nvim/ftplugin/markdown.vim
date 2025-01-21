if exists('b:did_ftplugin') | finish | endif
let b:did_ftplugin = 1

setlocal completefunc=notes#complete#completefunc

augroup ncm2_notes
    autocmd!
    autocmd BufEnter * call ncm2#enable_for_buffer()
    autocmd User Ncm2Plugin call ncm2#register_source({
                \ 'name': 'notes',
                \ 'priority': 8,
                \ 'scope': ['markdown'],
                \ 'matcher': {'name': 'prefix', 'key': 'word'},
                \ 'sorter': 'none',
                \ 'word_pattern': s:ncm_word_pattern,
                \ 'complete_pattern': s:ncm_regexes,
                \ 'on_complete': ['ncm2#on_complete#omni',
                \     'notes#complete#completefunc'],
                \ })
augroup END

let s:ncm_word_pattern = '\w+[\w\s.-]*'
let s:ncm_regexes = [
            \ '^\s*-\s+\w*',
            \ '^\s*keywords\s*:\s+(\[\s*)?(\\@)?\w*',
            \ '^\s*keywords\s*:\s+(\[\s*)?(\\@)?(' ..
            \     s:ncm_word_pattern .. ',\s+)+\w*',
            \ '@\w*',
            \ ]
