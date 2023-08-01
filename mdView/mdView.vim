""" to-do
" Execute BufWritePost autocommand *only when* MdView has been called
" Finish reading usr_41.txt
" Consider whether or not BufWritePost is the right event
" Add browser option
" Add browser-specific option to focus or not to focus
" Add pandoc options (look to vimtex on latexmk)
" Define key bindings


""" Define function/command for preventing external commands from triggering 'hit enter' prompt

function s:silent(commands)
     execute 'silent ' .. a:commands
     redraw!
endfunction
command -nargs=1 Silent call s:silent(<q-args>)


""" Define 'complete' message after the style of VimTeX 'compilation complete' message

highlight MdComplete cterm=bold
function s:md_complete_message()
     echohl Type
     echo 'mdView: '
     echohl MdComplete
     echon 'Complete'
     echohl None
endfunction


""" Convert .md file to .html and open browser

function s:md_convert_view()
     let $FILENAME = expand("%")
     Silent !pandoc -f markdown -t html --template=github.html --css= -o ${FILENAME\%.md}.html $FILENAME
     " Open Safari first, to avoid html file opening twice bug
     Silent !open -ga safari
     " Close Safari's initial new tab
     Silent !osascript -e 'tell application "Safari" to close (every tab of every window whose name = "Start Page")'
     Silent !open -g ${FILENAME\%.md}.html
     unlet $FILENAME
     call s:md_complete_message()
endfunction

command MdView call s:md_convert_view()


""" Call s:md_convert_view() after :w, and clean up highlight style before quitting

augroup MdView
     autocmd!
     autocmd BufWritePost *.md call s:md_convert_view()
     autocmd BufWinLeave *.md highlight clear MdComplete
augroup END
