# Options and settings {{{1

setopt EXTENDED_GLOB
setopt IGNORE_EOF
setopt MENU_COMPLETE
setopt NO_LIST_BEEP
setopt RC_EXPAND_PARAM
setopt RC_QUOTES
setopt SHARE_HISTORY

SAVEHIST=1000000
# Load all history into memory, including the 20% more than $SAVEHIST allowed
# by SHARE_HISTORY
HISTSIZE=1200000

bindkey -v
bindkey -M vicmd '\C-o' accept-line-and-down-history

PS1="%F{14}%n@%m (%!) %1~ %# %f"

export LESSHISTFILE=- # no 'less' history file
export MANPAGER='nvim +Man!'
export TEXEDIT='nvim +%d %s'

# Set up fzf shell integration
source <(fzf --zsh)

# Use 'fd' instead of 'find'
export FZF_DEFAULT_COMMAND='fd --hidden --type f --strip-cwd-prefix'
export FZF_CTRL_T_COMMAND='fd --hidden --strip-cwd-prefix'

# Options for 'rfv' script
export RFV_DEFAULT_BIND='--bind=enter:become(nvim {1} +{2})'
export -T RFV_DEFAULT_ADDITIONAL_OPTIONS rfv_default_additional_options '@'
rfv_default_additional_options=( --bind='ctrl-o:become(md-open {1})' )

export GPG_TTY="$(tty)" # Required by 'gpg-agent'

# User functions {{{1

autoload autoload_init
autoload_init

autoload alias_init
alias_init

autoload mk4
autoload cs
autoload default_gpg
autoload default_tar
autoload kpsewhich_nvim
autoload man_zsh
autoload nvim_help
autoload trash

# Install run-help {{{1
if unalias run-help 2>/dev/null; then
    autoload -U run-help
    autoload -U run-help-git
    export HELPDIR='/usr/share/zsh/5.9/help'
fi

# Initialize completion {{{1
if autoload -U compinit 2>/dev/null; then
    compinit
    zmodload zsh/complist
    zstyle ':completion*:default' menu 'select=0'
fi

# Aliases {{{1

# Edit {{{2
alias ebib="nvim $HOME/Library/texmf/bibtex/bib/my_library.bib"
alias egi="nvim $XDG_CONFIG_HOME/git/ignore"
alias ek="nvim $XDG_CONFIG_HOME/kitty/kitty.conf"
alias elmk="nvim $XDG_CONFIG_HOME/latexmk/latexmkrc"
alias es="nvim $HOME/Library/texmf/tex/latex/rhelder/rhelder.sty"
alias etf="nvim $XDG_CONFIG_HOME/nvim/ftplugin/tex.vim"
alias ev="nvim $XDG_CONFIG_HOME/nvim/init.vim"
alias ez="nvim $XDG_CONFIG_HOME/zsh/.zshrc"

# Navigate {{{2
alias b="cs $HOME/.local/bin"
alias -f dc="cs $HOME/Documents"
alias dg="cs $HOME/Documents/Git"
alias dn="cs $HOME/Documents/Notes"
alias gh="cs $XDG_CONFIG_HOME/git"
alias nca="cs $XDG_CONFIG_HOME/nvim/autoload"
alias ncc="cs $XDG_CONFIG_HOME/nvim/compiler"
alias ncf="cs $XDG_CONFIG_HOME/nvim/ftplugin"
alias nch="cs $XDG_CONFIG_HOME/nvim"
alias nci="cs $XDG_CONFIG_HOME/nvim/indent"
alias ncp="cs $XDG_CONFIG_HOME/nvim/plugin"
alias ncs="cs $XDG_CONFIG_HOME/nvim/spell"
alias ncz="cs $XDG_CONFIG_HOME/nvim/after"
alias nda="cs $XDG_DATA_HOME/nvim/site/autoload"
alias ndc="cs $XDG_DATA_HOME/nvim/site/compiler"
alias ndf="cs $XDG_DATA_HOME/nvim/site/ftplugin"
alias ndh="cs $XDG_DATA_HOME/nvim/site"
alias ndi="cs $XDG_DATA_HOME/nvim/site/indent"
alias -f ndp="cs $XDG_DATA_HOME/nvim/site/plugin"
alias nds="cs $XDG_DATA_HOME/nvim/site/spell"
alias ndz="cs $XDG_DATA_HOME/nvim/site/after"
alias nr='cs /opt/homebrew/Cellar/neovim/0.10.1/share/nvim/runtime'
alias pc="cs $XDG_DATA_HOME/pandoc/custom"
alias pd="cs $XDG_DATA_HOME/pandoc/defaults"
alias ph="cs $XDG_DATA_HOME/pandoc"
alias pm="cs $XDG_DATA_HOME/pandoc/metadata"
alias pt="cs $XDG_DATA_HOME/pandoc/templates"
alias py="cs $XDG_DATA_HOME/pandoc/styles"
alias th="cs $HOME/Library/texmf"
alias tl="cs $HOME/Library/texmf/tex/latex"
alias vt="cs $XDG_DATA_HOME/nvim/plugged/vimtex"
alias xc="cs $XDG_CONFIG_HOME"
alias xd="cs $XDG_DATA_HOME"
alias zh="cs $XDG_CONFIG_HOME/zsh"
alias zf="cs $XDG_DATA_HOME/zsh/functions"

# Abbreviate {{{2
alias cpm="cp -i $XDG_DATA_HOME/pandoc/Makefile ."
alias dgpg='default_gpg'
alias dtar='default_tar'
alias j="jobs"
alias kv="kpsewhich_nvim"
alias la='ls -aF'
alias -f ld='lilydoc'
alias lua='texlua'
alias m='man'
alias mz='man_zsh'
alias nb='browse-notes'
alias ni='browse-index'
alias nj='new-journal'
alias nn='new-note'
alias ns='search-notes'
alias nv='nvim'
alias nvh='nvim_help'
alias o='open'
alias si='kitten ssh rhelder@192.168.0.129'
alias sz="source $XDG_CONFIG_HOME/zsh/.zshrc"
alias td='texdoc'
alias ts='trash'

# Git {{{2
alias -f git='hub'
alias ga='git add'
alias gb='git branch'
alias gbD='git branch -D'
alias gbd='git branch -d'
alias gbl='git branch --list'
alias gc='git commit'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --pretty=short'
alias glg='git log --graph'
alias gll='git log'
alias gpl='git pull'
alias gpsh='git push'
alias gr='git reset'
alias -f gs='git status'
alias gsh='git show'
alias gsmu='git submodule update --remote --merge'
alias gst='git stash'
alias gstp='git stash pop'
alias gsw='git switch'
alias gswc='git switch -c'
# }}}2

# Shell variables {{{1

# Files {{{2
bib="$HOME/Library/texmf/bibtex/bib/my_library.bib"
gi="$XDG_CONFIG_HOME/git/ignore"
k="$XDG_CONFIG_HOME/kitty/kitty.conf"
lmk="$XDG_CONFIG_HOME/latexmk/latexmkrc"
v="$XDG_CONFIG_HOME/nvim/init.vim"
zv="$XDG_CONFIG_HOME/nvim/zshrc.vim"
tf="$XDG_CONFIG_HOME/nvim/ftplugin/tex.vim"
s="$HOME/Library/texmf/tex/latex/rhelder/rhelder.sty"
z="$XDG_CONFIG_HOME/zsh/.zshrc"

# Directories {{{2
b="$HOME/.local/bin"
dc="$HOME/Documents"
dg="$HOME/Documents/Git"
dn="$HOME/Documents/Notes"
gh="$XDG_CONFIG_HOME/git"
nca="$XDG_CONFIG_HOME/nvim/autoload"
ncc="$XDG_CONFIG_HOME/nvim/compiler"
ncf="$XDG_CONFIG_HOME/nvim/ftplugin"
nch="$XDG_CONFIG_HOME/nvim"
nci="$XDG_CONFIG_HOME/nvim/indent"
ncp="$XDG_CONFIG_HOME/nvim/plugin"
ncs="$XDG_CONFIG_HOME/nvim/spell"
ncz="$XDG_CONFIG_HOME/nvim/after"
nda="$XDG_DATA_HOME/nvim/site/autoload"
ndc="$XDG_DATA_HOME/nvim/site/compiler"
ndf="$XDG_DATA_HOME/nvim/site/ftplugin"
ndh="$XDG_DATA_HOME/nvim/site"
ndi="$XDG_DATA_HOME/nvim/site/indent"
ndp="$XDG_DATA_HOME/nvim/site/plugin"
nds="$XDG_DATA_HOME/nvim/site/spell"
ndz="$XDG_DATA_HOME/nvim/site/after"
nr='/opt/homebrew/Cellar/neovim/0.10.1/share/nvim/runtime'
pc="$XDG_DATA_HOME/pandoc/custom"
pd="$XDG_DATA_HOME/pandoc/defaults"
ph="$XDG_DATA_HOME/pandoc"
pm="$XDG_DATA_HOME/pandoc/metadata"
pt="$XDG_DATA_HOME/pandoc/templates"
py="$XDG_DATA_HOME/pandoc/styles"
th="$HOME/Library/texmf"
tl="$HOME/Library/texmf/tex/latex"
vt="$XDG_DATA_HOME/nvim/plugged/vimtex"
xc="$XDG_CONFIG_HOME"
xd="$XDG_DATA_HOME"
zh="$XDG_CONFIG_HOME/zsh"
zf="$XDG_DATA_HOME/zsh/functions"
# }}}2

# }}}1
