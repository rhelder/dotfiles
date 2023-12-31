# to-do
# * Add gpg-related functions
# * Consider completion options
# * Consider changing aliases related to the following that don't make good Vim
#   mappings:
#   - ez
#   - pd
#   - d
# * Turn `Cl` and `cl` into functions with error messages

# {{{1 Options and settings

setopt extended_glob
setopt ignore_eof
setopt rc_expand_param
setopt rc_quotes

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

# Use `autoload` and `alias` functions instead of builtins

declare -gi autoload_zshrc_sourced=0
if [[ $(whence -w autoload) == 'autoload: function' ]]; then
    autoload -f autoload
else
    autoload autoload
fi

declare -gi alias_zshrc_sourced=0
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

# {{{1 Aliases

alias bin="cd $HOME/.local/bin"
alias Cl="ts ^*.(((tex)|(latex)|(sty)|(dtx)|(bib)|(txt)|(md)|(vim)))(.)"
alias cl="ts ^*.(((tex)|(latex)|(sty)|(dtx)|(bib)|(txt)|(md)|(vim)|(pdf)))(.)"
alias d="cd $HOME/Documents"
alias dg="cd $HOME/Documents/Git"
alias ea="nvim $HOME/Library/texmf/tex/latex/aristotelis/aristotelis.sty"
alias ebib="nvim $HOME/Library/texmf/bibtex/bib/myLibrary.bib"
alias ebt="open $HOME/Documents/budget_2023.xlsx"
alias edf="nvim $XDG_CONFIG_HOME/git/filter-repo/dotfiles"
alias efzf="nvim $XDG_CONFIG_HOME/fzf/fzf.zsh"
alias egc="nvim $XDG_CONFIG_HOME/git/config"
alias egi="nvim $XDG_CONFIG_HOME/git/ignore"
alias eh='sudo nvim /etc/hosts'
alias elmk="nvim $XDG_CONFIG_HOME/latexmk/latexmkrc"
alias emd="nvim $XDG_DATA_HOME/nvim/site/ftplugin/markdown/mdView.vim"
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
alias on="cd $HOME/Documents/Notes"
alias pd="cd $XDG_DATA_HOME/pandoc"
alias pdd="cd $XDG_DATA_HOME/pandoc/defaults"
alias pdt="cd $XDG_DATA_HOME/pandoc/templates"
alias restart='[[ $(jobs) ]] && unset FPATH && PATH=/bin && exec -l zsh'
alias sz="source $XDG_CONFIG_HOME/zsh/.zshrc"
alias szp="source $XDG_CONFIG_HOME/zsh/.zprofile"
alias td='texdoc'
alias tdc="nvim $HOME/Library/texmf/texdoc/texdoc.cnf"
alias ts='trash'
alias ucb="cd $HOME/Documents/Past/2019-2024_UCBerkeley"
alias vcc="ts $XDG_CACHE_HOME/vimtex/pkgcomplete.json"
alias vmc="cd $XDG_CONFIG_HOME/nvim/vimtex_my_complete"
alias vtc="cd $XDG_DATA_HOME/nvim/plugged/vimtex/autoload/vimtex/complete"
alias xch="cd $XDG_CONFIG_HOME"
alias xdh="cd $XDG_DATA_HOME"
alias zf="cd $XDG_DATA_HOME/zsh/functions"

# {{{1 Shell variables

a=$HOME/Library/texmf/tex/latex/aristotelis/aristotelis.sty
bib=$HOME/Library/texmf/bibtex/bib/myLibrary.bib
bin=$HOME/.local/bin
d=$HOME/Documents
df=$XDG_CONFIG_HOME/git/filter-repo/dotfiles
dg=$HOME/Documents/Git
fzf=$XDG_CONFIG_HOME/fzf/fzf.zsh
gc=$XDG_CONFIG_HOME/git/config
gi=$XDG_CONFIG_HOME/git/ignore
lmk=$XDG_CONFIG_HOME/latexmk/latexmkrc
md=$XDG_DATA_HOME/nvim/site/ftplugin/markdown/mdView.vim
pdd=$XDG_DATA_HOME/pandoc/defaults
pdt=$XDG_DATA_HOME/pandoc/templates
rhc=$HOME/Library/texmf/tex/latex/rhelder-cvcls/rhelder-cv.cls
s=$HOME/Library/texmf/tex/latex/rhelder/rhelder.sty
spd=$XDG_CONFIG_HOME/nvim/spell/de.utf-8.add
spe=$XDG_CONFIG_HOME/nvim/spell/en.utf-8.add
tdc=$HOME/Library/texmf/texdoc/texdoc.cnf
ucb=$HOME/Documents/Past/2019-2024_UCBerkeley
n=$HOME/Documents/Notes
v=$XDG_CONFIG_HOME/nvim/init.vim
vmc=$XDG_CONFIG_HOME/nvim/vimtex_my_complete
vtc=$XDG_DATA_HOME/nvim/plugged/vimtex/autoload/vimtex/complete
xch=$XDG_CONFIG_HOME
xdh=$XDG_DATA_HOME
z=$XDG_CONFIG_HOME/zsh/.zshrc
zf=$XDG_DATA_HOME/zsh/functions
zp=$XDG_CONFIG_HOME/zsh/.zprofile

# }}}1
