function! notes#mdview#output_file() abort dict " {{{1
    " If the input file is an index file, manipulate the filename so that the
    " html filename is exactly equivalent to the corresponding keyword, so that
    " it can be linked to in a Pandoc template
    let l:input = self.input()
    let l:head = fnamemodify(l:input, ':h')
    let l:tail = fnamemodify(l:input, ':t')
    let l:tail = substitute(l:tail, '^_', '@', '')
    let l:tail = substitute(l:tail, '_', ' ', 'g')
    let l:tail = substitute(l:tail, '.md$', '.html', '')
    let l:output = l:head .. '/' .. l:tail
    return l:output
endfunction

" }}}1
