let $FILENAME = expand("%")
silent !pandoc -f markdown -t html --template=github.html --css= -o ${FILENAME\%.md}.html $FILENAME
silent !open -ga safari
" !osascript close_tab.scpt
silent !osascript -e 'tell application "Safari" to close (every tab of every window whose name = "Start Page")'
silent !open -g ${FILENAME\%.md}.html
unlet $FILENAME
