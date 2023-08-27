# {{{1 Options and settings

HISTSIZE=1200000
SAVEHIST=1000000
setopt extended_glob
setopt rcquotes

# Set prompt
PS1="%F{14}%n@%m (%!) %1~ %# %f"

# Set Neovim as man pager
export MANPAGER='nvim +Man!'

# No .lesshst file
export LESSHISTFILE=-

# Configure gpg-agent
export GPG_TTY=$(tty)
# Use TTY-based pinentry (rather than pinentry-mac) in most cases (glitched
# for me)
# export PINENTRY_USER_DATA="USE_CURSES=1"

# {{{1 Variables

arist="$(kpsewhich aristotelis.sty)"
bib="$(kpsewhich myLibrary.bib)"
db="$HOME/Library/CloudStorage/Dropbox"
nvimrc="$HOME/.config/nvim/init.vim"
rhelder="$(kpsewhich rhelder.sty)"
texmf="$HOME/Library/texmf"
ucb="$db/UCBerkeley"
vtc="$HOME/.local/share/nvim/site/vimtex/autoload/vimtex/complete"
zshrc="$HOME/.zshrc"

# {{{1 Aliases

alias bib="cd $(dirname $bib)"
alias bt="open $db/budget_2023.xlsx"
alias Cl="mv ^*.(((tex)|(sty)|(bib)|(txt)|(md)|(vim))) $HOME/.Trash"
alias cl="mv ^*.(((tex)|(sty)|(bib)|(txt)|(md)|(vim)|(pdf))) $HOME/.Trash"
alias db="cd $db"
alias ea="nvim $arist"
alias es="nvim $rhelder"
alias ev="nvim $HOME/.config/nvim/init.vim"
alias ez="nvim $HOME/.zshrc"
alias hf='sudo nvim /etc/hosts'
alias lqs='open -a skim "$HOME/Documents/Books/lua_quickStart.pdf"'
alias ls='ls -aF'
alias lua='luajit'
alias mhd='lsof ''/Volumes/RH Media HD/iTunes/Apple Music Library/Music Library.musiclibrary/Library.musicdb''; \
     lsof ''/Volumes/RH Media HD/Apple TV/TV Library.tvlibrary/Library.tvdb'''
alias sz="source $zshrc"
alias ucb="cd $db/UCBerkeley"
alias vcc="trash $HOME/.cache/vimtex/pkgcomplete.json"
alias vtc="cd $HOME/.local/share/nvim/site/vimtex/autoload/vimtex/complete"

# {{{1 Functions

# User-defined functions
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

# Install run-help
if [[ $(alias -m run-help) != '' ]]
     then unalias run-help
fi
autoload -Uz run-help
autoload -Uz run-help-git
# Set Neovim as pager for run-help
functions -c run-help run-help-def
function run-help {
     local HELPDIR='/usr/share/zsh/5.9/help'
     local PAGER='nvim +silent!Man!'
     run-help-def $*
}
