# General {{{1

# Prompt (powerlevel10k)
if [[ -r "$XDG_CACHE_HOME/.cache/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "$XDG_CACHE_HOME/.cache/p10k-instant-prompt-${(%):-%n}.zsh"
fi
source $XDG_DATA_HOME/powerlevel10k/powerlevel10k.zsh-theme
source $ZDOTDIR/.p10k.zsh

# Options
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

# Use Neovim as pager
export MANPAGER='nvim +Man!'
export TEXEDIT='nvim +%d %s'

# Key bindings
bindkey -v
bindkey -M vicmd '\C-o' accept-line-and-down-history
bindkey -M viins '\C-o' accept-line-and-down-history
bindkey -M viins '\C-u' kill-whole-line
bindkey -M viins '\C-y' yank
bindkey -M viins '\C-xu' undo
bindkey -M viins '\C-x\C-u' undo
bindkey -M vicmd 'K' run-help
if unalias run-help 2>/dev/null; then # Install run-help (only once)
  autoload -U run-help
  autoload -U run-help-git
  export HELPDIR='/usr/share/zsh/5.9/help'
fi

# Completion {{{1

# Only load and run 'compinit' once
if [[ ! -n $(whence compinit) ]]; then
  autoload -U compinit
  [[ ! -d $XDG_CACHE_HOME/.zcompcache ]] && mkdir $XDG_CACHE_HOME/.zcompcache
  compinit -d $XDG_CACHE_HOME/.zcompcache/.zcompdump
  zmodload zsh/complist
fi

zstyle ':completion:*' cache-path $XDG_CACHE_HOME/.zcompcache
zstyle ':completion:*:messages' format %d
zstyle ':completion:*:warnings' format 'No matches: %d'
zstyle ':completion:*:descriptions' format %B%d%b
zstyle ':completion:*' group-name ''
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*:default' menu 'select=0'

bindkey -M menuselect '\C-e' undo
bindkey -M menuselect '\C-o' accept-and-menu-complete
# Use 'TAB' to accept the current match, and then expand or complete again
# (this makes it easier to quickly complete e.g. file paths)
bindkey -M menuselect '\C-i' .expand-or-complete
# Use '^N', not 'TAB', to move to the next match
bindkey -M menuselect '\C-n' menu-complete
bindkey -M menuselect '\C-p' reverse-menu-complete

# User functions {{{1

autoload mk4
autoload cs
autoload default_gpg
autoload default_tar
autoload kpsewhich_nvim
autoload man_zsh
autoload nvim_help

# Aliases {{{1

# Edit {{{2

alias ebib="nvim $HOME/Library/texmf/bibtex/bib/my_library.bib"
alias egi="nvim $XDG_CONFIG_HOME/git/ignore"
alias ek="nvim $XDG_CONFIG_HOME/kitty/kitty.conf"
alias elmk="nvim $XDG_CONFIG_HOME/latexmk/latexmkrc"
alias emf="nvim $XDG_CONFIG_HOME/nvim/ftplugin/markdown.vim"
alias ep="nvim $XDG_CONFIG_HOME/zsh/.p10k.zsh"
alias es="nvim $HOME/Development/rhelder/rhelder.dtx"
alias etf="nvim $XDG_CONFIG_HOME/nvim/ftplugin/tex.vim"
alias ev="nvim $XDG_CONFIG_HOME/nvim/init.vim"
alias ez="nvim $XDG_CONFIG_HOME/zsh/.zshrc"

# Navigate {{{2

alias b="cs $HOME/.local/bin"
alias dc="cs $HOME/Documents"
alias dg="cs $HOME/Documents/Drafts"
alias dn="cs $HOME/Documents/Notes"
alias dp="cs $HOME/Documents/Personal"
alias ds="cs $HOME/Development/rhelder"
alias dt="cs $HOME/Development/Tests"
alias dv="cs $HOME/Development"
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
alias ndp="cs $XDG_DATA_HOME/nvim/site/plugin"
alias np="cs $XDG_DATA_HOME/nvim/plugged"
alias nr='cs /opt/homebrew/Cellar/neovim/*/share/nvim/runtime'
alias p1="cs $XDG_DATA_HOME/powerlevel10k"
alias p2="cs $HOME/Documents/2"
alias pc="cs $XDG_DATA_HOME/pandoc/custom"
alias pd="cs $XDG_DATA_HOME/pandoc/defaults"
alias ph="cs $XDG_DATA_HOME/pandoc"
alias pm="cs $XDG_DATA_HOME/pandoc/metadata"
alias pt="cs $XDG_DATA_HOME/pandoc/templates"
alias py="cd $XDG_DATA_HOME/pandoc/csl"
alias th="cs $HOME/Library/texmf"
alias tl="cs $HOME/Library/texmf/tex/latex"
alias vt="cs $XDG_DATA_HOME/nvim/vimtex"
alias xc="cs $XDG_CONFIG_HOME"
alias xd="cs $XDG_DATA_HOME"
alias zf="cs $XDG_DATA_HOME/zsh/functions"
alias zh="cs $XDG_CONFIG_HOME/zsh"

# Abbreviate {{{2

alias cpm="cp -i $XDG_DATA_HOME/pandoc/Makefile ."
alias dgpg='default_gpg'
alias dtar='default_tar'
alias j="jobs"
alias kv="kpsewhich_nvim"
alias la='ls -aF'
alias ld='lilydoc'
alias lua='pandoc lua'
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
alias sp="source $XDG_CONFIG_HOME/zsh/.p10k.zsh"
alias sz="source $XDG_CONFIG_HOME/zsh/.zshrc"
alias td='texdoc'
alias ts='trash'

# Git {{{2

alias git='hub'

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
alias gp='git pull'
alias gr='git reset'
alias gs='git status'
alias gsh='git show'
alias gsmu='git submodule update --remote --merge'
alias gst='git stash'
alias gstp='git stash pop'
alias gsw='git switch'
alias gswc='git switch -c'
alias gu='git push'

# }}}2

# Shell variables {{{1

# Files {{{2

bib="$HOME/Library/texmf/bibtex/bib/my_library.bib"
gi="$XDG_CONFIG_HOME/git/ignore"
k="$XDG_CONFIG_HOME/kitty/kitty.conf"
lmk="$XDG_CONFIG_HOME/latexmk/latexmkrc"
mf="$XDG_CONFIG_HOME/nvim/ftplugin/markdown.vim"
p="$XDG_CONFIG_HOME/zsh/.p10k.zsh"
s="$HOME/Development/rhelder/rhelder.dtx"
tf="$XDG_CONFIG_HOME/nvim/ftplugin/tex.vim"
v="$XDG_CONFIG_HOME/nvim/init.vim"
z="$XDG_CONFIG_HOME/zsh/.zshrc"
zv="$XDG_CONFIG_HOME/nvim/zshrc.vim"

# Directories {{{2

b="$HOME/.local/bin"
dc="$HOME/Documents"
dg="$HOME/Documents/Drafts"
dn="$HOME/Documents/Notes"
dn="$HOME/Documents/Notes"
dp="$HOME/Documents/Personal"
ds="$HOME/Development/rhelder"
dt="$HOME/Development/Tests"
dv="$HOME/Development"
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
ndp="$XDG_DATA_HOME/nvim/site/plugin"
np="$XDG_DATA_HOME/nvim/plugged"
nr='/opt/homebrew/Cellar/neovim/*/share/nvim/runtime'
p1="$XDG_DATA_HOME/powerlevel10k"
p2="$HOME/Documents/2"
pc="$XDG_DATA_HOME/pandoc/custom"
pd="$XDG_DATA_HOME/pandoc/defaults"
ph="$XDG_DATA_HOME/pandoc"
pm="$XDG_DATA_HOME/pandoc/metadata"
pt="$XDG_DATA_HOME/pandoc/templates"
py="$XDG_DATA_HOME/pandoc/csl"
th="$HOME/Library/texmf"
tl="$HOME/Library/texmf/tex/latex"
vt="$XDG_DATA_HOME/nvim/vimtex"
xc="$XDG_CONFIG_HOME"
xd="$XDG_DATA_HOME"
zf="$XDG_DATA_HOME/zsh/functions"
zh="$XDG_CONFIG_HOME/zsh"

# }}}2

# Command-line tools {{{1

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

# }}}1
