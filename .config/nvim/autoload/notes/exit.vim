function! notes#exit#compile() abort " {{{1
  if !filereadable(expand('%')) | return | endif

  if string(v:exiting) ==# 'v:null'
    if !getbufvar(expand('<afile>'), 'modified', 0) | return | endif

    let l:title = ['[Warning] mdView', '[Error] mdView']
    if !empty(shell#get_scratch_buf())
      call shell#set_scratch_buf({'title': l:title})
    endif

    call mdview#compiler#convert(1, {
          \ 'scratch_buf': {
          \   'title': l:title,
          \ },
          \ 'bufnr': bufnr(expand('<afile>')),
          \ 'callback': function('s:mdview_callback'),
          \ })

  else
    if getbufvar(expand('<afile>'), 'modified', 0)
      call mdview#compiler#convert(0, {'sync': 1})
    endif

    if get(s:, 'modified', 0)
      call shell#compile(['build-index'], {'sync': 1})
      let s:modified = 0
    endif
  endif
endfunction

function! s:mdview_callback(job, status, event) abort dict " {{{2
  if a:event !=# 'exit' | return | endif

  call setbufvar(bufname(self.bufnr), 'modified', 0)

  if !s:modified | return | endif

  let l:scratch_buf = shell#get_scratch_buf()
  if bufwinid(get(l:scratch_buf, 'bufnr', -1)) >=# 0
    let self.matches = getmatches(bufwinid(l:scratch_buf.bufnr))
  else
    let self.matches = []
  endif

  call shell#compile(['build-index'], {
        \ 'mdview': self,
        \ 'on_error': function('s:build_index_on_error'),
        \ 'info': 'build-index',
        \ 'callback': function('s:build_index_callback'),
        \ })
endfunction

function! s:build_index_on_error(job, status, event) abort dict " {{{2
  if empty(self.stderr()) | return | endif

  call extend(self.output, self.mdview.output, 0)

  let self.scratch = 5

  let l:title = ['[Warning] build-index', '[Error] build-index']
  let l:scratch_buf = shell#get_scratch_buf()
  if empty(l:scratch_buf)
    let self.scratch_buf = self.mdview.scratch_buf
    let self.scratch_buf.title = l:title
  else
    if !empty(self.mdview.stderr())
      let l:title = [
            \ bufname(l:scratch_buf.bufnr) .. ' ' .. l:title[0],
            \ bufname(l:scratch_buf.bufnr) .. ' ' .. l:title[1],
            \ ]
    endif
    call shell#set_scratch_buf({'title': l:title})
  endif

  call self.load_scratch_buf(a:job, a:status, a:event)

  if empty(self.mdview.matches) | return | endif

  let l:match = self.mdview.matches[-1]
  let l:match.pos = []
  for [l:key, l:val] in items(l:match)
    if l:key =~# '\vpos\d+'
      call extend(l:match.pos, l:val)
    endif
  endfor

  call matchaddpos(
        \ l:match.group,
        \ l:match.pos,
        \ l:match.priority + 1,
        \ -1,
        \ {'window': bufwinid(l:scratch_buf.bufnr)},
        \ )
endfunction

function! s:build_index_callback(job, status, event) abort dict " {{{2
  let s:modified = 0
endfunction
" }}}2

function! notes#exit#set_modified(...) " {{{1
  let s:modified = a:0

  let l:file = expand('<afile>')
  if empty(l:file)
    let l:file = expand('%')
  endif

  if exists('a:1')
    call setbufvar(l:file, 'modified', a:1)
  endif
endfunction

" }}}1
