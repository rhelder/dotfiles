" to-do
" *  Finish reading usr_41.txt
" *  Consider whether or not BufWritePost is the right event
" *  Add browser option
" *  Add browser-specific option to focus or not to focus
" *  Add pandoc options (look to vimtex on latexmk)
" *  Define key bindings


" Define function/command for preventing external commands from triggering
" 'hit enter' prompt

function s:silent(commands)
     execute 'silent ' .. a:commands
     redraw!
endfunction
command -nargs=1 Silent call s:silent(<q-args>)


" Define 'completed' and 'stopped' messages after the style of VimTeX
" 'compilation complete' and 'complitation stopped' messages

highlight MdMessage cterm=bold
function s:message_completed()
     echohl Type
     echo 'mdView: '
     echohl MdMessage
     echon 'Completed'
     echohl None
endfunction

function s:message_stopped()
     echohl Type
     echo 'mdView: '
     echohl MdMessage
     echon 'Stopped'
     echohl None
endfunction


" Define function that converts .md file to .html and opens browser

function s:convert_and_view()
     let $FILENAME = expand("%")
     Silent !pandoc -f markdown -t html --template=github.html --css= -o ${FILENAME\%.md}.html $FILENAME
     " Open Safari first, to avoid html file opening twice bug
     Silent !open -ga safari
     " Close Safari's initial new tab
     Silent !osascript -e 'tell application "Safari" to close (every tab of every window whose name = "Start Page")'
     Silent !open -g ${FILENAME\%.md}.html
     unlet $FILENAME
     call s:message_completed()
endfunction


" Define function that calls s:convert_and_view() and defines autocmd such
" that s:convert_and_view() is called whenever the buffer is written, but
" 'turns off' when it is called a second time.

let s:viewed = 0

function s:md_view()
     if s:viewed == 0
	  call s:convert_and_view()
	  augroup md_write_and_view
	       autocmd!
	       autocmd BufWritePost *.md call s:convert_and_view()
	  augroup END
	  let s:viewed = 1
     elseif s:viewed == 1
	  augroup md_write_and_view
	       autocmd!
	  augroup END
	  call s:message_stopped()
	  let s:viewed = 0
     endif
endfunction

command Mdview call s:md_view()	   " Wrap the function in a command


" Clean up highlight style before quitting

augroup md_cleanup
     autocmd!
     autocmd BufWinLeave *.md highlight clear MdMessage
augroup END
