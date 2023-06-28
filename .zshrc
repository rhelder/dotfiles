# Options
export MANPAGER='nvim +Man!'
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
alias aristotelis="cd $(dirname $(kpsewhich aristotelis.sty))"
alias budget="open $HOME/Library/CloudStorage/Dropbox/Budget_2023.xlsx" 
alias clean="mv *.[^tp]* $HOME/.Trash"
alias Clean="mv *.[^t]* $HOME/.Trash"
alias db="cd $HOME/Library/CloudStorage/Dropbox"
alias ls='ls -aF'
alias lua='luajit'
alias luaqs='open -a skim '/Users/rhelder/Documents/Other/Lua_Quick_Start_Guide_The_Easiest_Way_to_Learn_Lua....pdf''
alias nvimrc="nvim $HOME/.config/nvim/init.vim"
alias reload="source $HOME/.zshrc"
alias rhelder="cd $(dirname $(kpsewhich rhelder.sty))"
alias rhmhd='lsof +D '/Volumes/RH Media HD/''
alias ucb="cd $HOME/Library/CloudStorage/Dropbox/UCBerkeley"
alias vtc="cd $HOME/.config/nvim/pack/plugins/start/vimtex/autoload/vimtex/complete"
alias zshrc="nvim $HOME/.zshrc"
function cs {
     cd $* && ls
}
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
RHELDER="$(dirname $(kpsewhich rhelder.sty))"
UCB="$HOME/Library/CloudStorage/Dropbox/UCBerkeley"
VTC="$HOME/.config/nvim/pack/plugins/start/vimtex/autoload/vimtex/complete"
ZSHRC="$HOME/.zshrc"
