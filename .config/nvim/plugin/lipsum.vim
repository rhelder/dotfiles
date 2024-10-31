if exists('g:loaded_lipsum') | finish | endif
let g:loaded_lipsum = 1

command -nargs=* Lipsum call lipsum#insert(<f-args>)
