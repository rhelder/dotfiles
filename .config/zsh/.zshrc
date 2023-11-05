# to-do
# * Add gpg-related functions
# * Consider completion options

# {{{1 Options and settings

setopt extended_glob
setopt ignore_eof
setopt local_traps
setopt rc_expand_param
setopt rc_quotes
setopt typeset_silent

# History
HISTSIZE=1200000
SAVEHIST=1000000
setopt append_history

# Set prompt
PS1="%F{14}%n@%m (%!) %1~ %# %f"

# Set Neovim as man pager
export MANPAGER='nvim +Man!'

# No .lesshst file
export LESSHISTFILE=-

# Configure gpg-agent
export GPG_TTY="$(tty)"

# Source `fzf` preferences
source $XDG_CONFIG_HOME/fzf/fzf.zsh

# {{{1 Functions

# Redefine `autoload` and `alias`

# If `autoload` has already been redefined, use `-f` flag so that any changes
# made by user are loaded
if [[ ${"$(whence -w autoload)"##*: } == 'function' ]]; then
    autoload -f autoload
else
    # Otherwise, load function definition
    autoload autoload
fi

autoload -f alias

# Load other user functions
autoload cs
autoload mktar
autoload mz
autoload nvim-help
autoload trash
autoload untar

# Install run-help
[[ ${"$(whence -w run-help)"##*: } == 'alias' ]] && unalias run-help
autoload -Uz run-help
autoload -Uz run-help-git
export HELPDIR='/usr/share/zsh/5.9/help'

dummy() {
    echo $funcfiletrace
}

# {{{1 Aliases

# Define/clear `zshrc_aliases` array used by `alias` function to make sure that
# the same alias name is not used twice
zshrc_aliases=()

alias bin="cd $HOME/.local/bin"
alias Cl="ts ^*.(((tex)|(latex)|(sty)|(dtx)|(bib)|(txt)|(md)|(vim)))(.)"
alias cl="ts ^*.(((tex)|(latex)|(sty)|(dtx)|(bib)|(txt)|(md)|(vim)|(pdf)))(.)"
alias doc="cd $HOME/Documents"
alias ea="nvim $HOME/Library/texmf/tex/latex/aristotelis/aristotelis.sty"
alias ebib="nvim $(kpsewhich myLibrary.bib)"
alias ebt="open $HOME/Documents/budget_2023.xlsx"
alias edf="nvim $XDG_CONFIG_HOME/git/filter-repo/dotfiles"
alias efzf="nvim $XDG_CONFIG_HOME/fzf/fzf.zsh"
alias egc="nvim $XDG_CONFIG_HOME/git/config"
alias egi="nvim $XDG_CONFIG_HOME/git/ignore"
alias eh='sudo nvim /etc/hosts'
alias elmk="nvim $XDG_CONFIG_HOME/latexmk/latexmkrc"
alias erhc="nv $HOME/Library/texmf/tex/latex/rhelder-cvcls/rhelder-cv.cls"
alias es="nvim $HOME/Library/texmf/tex/latex/rhelder/rhelder.sty"
alias espd="nvim $XDG_CONFIG_HOME/nvim/spell/de.utf-8.add"
alias espe="nvim $XDG_CONFIG_HOME/nvim/spell/en.utf-8.add"
alias ev="nvim $XDG_CONFIG_HOME/nvim/init.vim"
alias ez="nvim $XDG_CONFIG_HOME/zsh/.zshrc"
alias ezh="nvim $HISTFILE"
alias ezp="nvim $XDG_CONFIG_HOME/zsh/.zprofile"
alias ga='git add'
alias gbD='git branch -D'
alias gbd='git branch -d'
alias gc='git commit'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --pretty=short'
alias gll='git log'
alias gpo='git pull origin'
alias gpom='git pull origin main'
alias gpuo='git push -u origin'
alias gpuom='git push -u origin main'
alias gr='git reset'
alias gs='git status'
alias gsmu='git submodule update --remote --merge'
alias gsw='git switch'
alias gswc='git switch -c'
alias la='ls -aF'
alias lua='luajit'
alias m='man'
alias nj='new-journal'
alias nn='new-note'
alias nv='nvim'
alias nvh='nvim-help'
alias o='open'
alias pd="cd $XDG_DATA_HOME/pandoc"
alias pdd="cd $XDG_DATA_HOME/pandoc/defaults"
alias pdt="cd $XDG_DATA_HOME/pandoc/templates"
alias restart='unset FPATH && PATH=/bin && exec -l zsh'
alias sz="source $XDG_CONFIG_HOME/zsh/.zshrc"
alias szp="source $XDG_CONFIG_HOME/zsh/.zprofile"
alias td='texdoc'
alias tdc="nv $HOME/Library/texmf/texdoc/texdoc.cnf"
alias ts='trash'
alias ucb="cd $HOME/Documents/UCBerkeley"
alias vcc="ts $XDG_CACHE_HOME/vimtex/pkgcomplete.json"
alias vmc="cd $XDG_CONFIG_HOME/nvim/vimtex_my_complete"
alias vtc="cd $XDG_DATA_HOME/nvim/plugged/vimtex/autoload/vimtex/complete"
alias xch="cd $XDG_CONFIG_HOME"
alias xdh="cd $XDG_DATA_HOME"
alias zf="cd $XDG_DATA_HOME/zsh/functions"

# {{{1 Shell variables

a=$HOME/Library/texmf/tex/latex/aristotelis/aristotelis.sty
bin=$HOME/.local/bin
df=$XDG_CONFIG_HOME/git/filter-repo/dotfiles
doc=$HOME/Documents
fzf=$XDG_CONFIG_HOME/fzf/fzf.zsh
gc=$XDG_CONFIG_HOME/git/config
gi=$XDG_CONFIG_HOME/git/ignore
lmk=$XDG_CONFIG_HOME/latexmk/latexmkrc
pdd=$XDG_DATA_HOME/pandoc/defaults
pdt=$XDG_DATA_HOME/pandoc/templates
rhc=$HOME/Library/texmf/tex/latex/rhelder-cvcls/rhelder-cv.cls
s=$HOME/Library/texmf/tex/latex/rhelder/rhelder.sty
spd=$XDG_CONFIG_HOME/nvim/spell/de.utf-8.add
spe=$XDG_CONFIG_HOME/nvim/spell/en.utf-8.add
ucb=$HOME/Documents/UCBerkeley
v=$XDG_CONFIG_HOME/nvim/init.vim
vmc=$XDG_CONFIG_HOME/nvim/vimtex_my_complete
vtc=$XDG_DATA_HOME/nvim/plugged/vimtex/autoload/vimtex/complete
xch=$XDG_CONFIG_HOME
xdh=$XDG_DATA_HOME
z=$XDG_CONFIG_HOME/zsh/.zshrc
zf=$XDG_DATA_HOME/zsh/functions
zp=$XDG_CONFIG_HOME/zsh/.zprofile
tdc=$HOME/Library/texmf/texdoc/texdoc.cnf


# }}}1
