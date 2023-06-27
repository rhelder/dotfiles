# Options
export MANPAGER='nvim +Man!'
HISTSIZE=1200000
SAVEHIST=1000000
setopt rcquotes


# run-help Settings
HELPDIR='/usr/share/zsh/5.9/help'
unalias run-help
autoload -Uz run-help
functions -c run-help run-help-def
function run-help {
     run-help-def $* | nvim -R -
}


# Prompt
PS1="%F{14}%n@%m (%!) %1~ %# %f"


# Aliases and Functions
alias lua='luajit'
alias aristotelis="cd $(dirname $(kpsewhich aristotelis.sty))"
alias budget="open $HOME/Library/CloudStorage/Dropbox/Budget_2023.xlsx" 
alias clean="mv *.[^tp]* $HOME/.Trash"
alias Clean="mv *.[^t]* $HOME/.Trash"
alias db="cd $HOME/Library/CloudStorage/Dropbox"
alias ls='ls -aF'
alias luaqs='open -a skim '/Users/rhelder/Documents/Other/Lua_Quick_Start_Guide_The_Easiest_Way_to_Learn_Lua....pdf''
alias nvimrc="nvim $HOME/.config/nvim/init.vim"
alias reload="source $HOME/.zshrc"
alias rhmhd='lsof +D '/Volumes/RH Media HD/''
alias template="cd $(dirname $(kpsewhich template.sty))"
alias ucb="cd $HOME/Library/CloudStorage/Dropbox/UCBerkeley"
alias updbib="sudo mv $HOME/Documents/LaTeX/Library.bib /usr/local/texlive/texmf-local/bibtex/bib"
alias vtc="cd $HOME/.config/nvim/pack/plugins/start/vimtex/autoload/vimtex/complete"
alias zshrc="nvim $HOME/.zshrc"
function ffr {
     sudo find / ${*:?Expression required.} -print 2>/dev/null > rm_files.txt
}
function nvimh {
     nvim -c "help $*" -c "only"
}
function trash {
     mv ${*:?What you want to move to Trash needs to be specified.} $HOME/.Trash
}


# Variables
ARISTOTELIS="$(dirname $(kpsewhich aristotelis.sty))"
DB="$HOME/Library/CloudStorage/Dropbox"
NVIMRC="$HOME/.config/nvim/init.vim"
TEMPLATE="$(dirname $(kpsewhich template.sty))"
UCB="$HOME/Library/CloudStorage/Dropbox/UCBerkeley"
VTC="$HOME/.config/nvim/pack/plugins/start/vimtex/autoload/vimtex/complete"
ZSHRC="$HOME/.zshrc"
