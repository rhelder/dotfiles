# Options

HISTSIZE=1200000
SAVEHIST=1000000
setopt rcquotes


# run-help Settings

HELPDIR='/usr/share/zsh/5.9/help'
if [[ $(alias -m run-help) != '' ]]
     then unalias run-help
fi
autoload -Uz run-help
functions -c run-help run-help-def
function run-help {
     run-help-def $* | nvim -R -
}


# Prompt

PS1="%F{14}%n@%m (%!) %1~ %# %f"


# Aliases and Functions

alias arist="nvim $HOME/Library/texmf/tex/latex/aristotelis/aristotelis.sty"
alias bib="cd $(dirname $(kpsewhich MyLibrary.bib))"
alias budget="open $HOME/Library/CloudStorage/Dropbox/budget_2023.xlsx"
alias clean="mv *.[^tp]* $HOME/.Trash"
alias Clean="mv *.[^t]* $HOME/.Trash"
alias db="cd $HOME/Library/CloudStorage/Dropbox"
alias ls='ls -aF'
alias lua='luajit'
alias luaqs='open -a skim "$HOME/Documents/Books/lua_quickStart.pdf"'
alias nvimrc="nvim $HOME/.config/nvim/init.vim"
alias reload="source $HOME/.zshrc"
alias rhelder="nvim $HOME/Library/texmf/tex/latex/rhelder/rhelder.sty"
alias rhmhd='lsof +D ''/Volumes/RH Media HD/'''
alias ucb="cd $HOME/Library/CloudStorage/Dropbox/UCBerkeley"
alias VimtexClearCache="trash $HOME/.cache/vimtex/pkgcomplete.json"
alias vtc="cd $HOME/.local/share/nvim/site/vimtex/autoload/vimtex/complete"
alias zshrc="nvim $HOME/.zshrc"
function cs {
     cd $* && ls
}
function ffr {
     sudo find / ${*:?Expression required.} -print 2>/dev/null > ~/rm_files.txt
}
function nvimh {
     nvim -c "help $*" -c "only"
}
function trash {
     mv ${*:?What you want to move to Trash needs to be specified.} $HOME/.Trash
}
function untar {
     file=${*:?Tarball must be specified.}
     mkdir ${file%.tar*}
     tar -xf $file -C ${file%.tar*}
}


# Variables

arist="$HOME/Library/texmf/tex/latex/aristotelis/aristotelis.sty"
db="$HOME/Library/CloudStorage/Dropbox"
export MANPAGER='nvim +Man!'
nvimrc="$HOME/.config/nvim/init.vim"
rhelder="$HOME/Library/texmf/tex/latex/rhelder/rhelder.sty"
texmf="$HOME/Library/texmf"
ucb="$HOME/Library/CloudStorage/Dropbox/UCBerkeley"
vtc="$HOME/.local/share/nvim/site/vimtex/autoload/vimtex/complete"
zshrc="$HOME/.zshrc"


# Configure gpg-agent

GPG_TTY=$(tty)
export GPG_TTY
# Use TTY-based pinentry (rather than pinentry-mac) in most cases
# export PINENTRY_USER_DATA="USE_CURSES=1"
