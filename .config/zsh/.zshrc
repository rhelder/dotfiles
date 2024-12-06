# {{{1 Options and settings

# zsh {{{2

setopt extended_glob
setopt ignore_eof
setopt menu_complete
setopt no_list_beep
setopt rc_expand_param
setopt rc_quotes
setopt share_history

# Expand saved history
HISTSIZE=1200000
SAVEHIST=1000000

# Set prompt
PS1="%F{14}%n@%m (%!) %1~ %# %f"

# Set Neovim as man pager
export MANPAGER='nvim +Man!'

# less {{{2

# No '.lesshst' file
export LESSHISTFILE=-

# fzf {{{2

# Set up fzf shell integration
source <(fzf --zsh)

# Use 'fd' instead of 'find'
export FZF_DEFAULT_COMMAND='fd --hidden --type f --strip-cwd-prefix'
export FZF_CTRL_T_COMMAND='fd --hidden --strip-cwd-prefix'

# rfv {{{2

export RFV_DEFAULT_BIND='--bind=enter:become(nvim {1} +{2})'
export -T RFV_DEFAULT_ADDITIONAL_OPTIONS rfv_default_additional_options '@'
rfv_default_additional_options=( --bind='ctrl-o:become(md-open {1})' )

# gpg-agent {{{2

export GPG_TTY="$(tty)"

# }}}2

# User functions {{{1

# Use my 'autoload' function instead of builtin
autoload autoload_init
autoload_init

# Use my 'alias' function instead of builtin
autoload alias_init
alias_init

# Load other user functions
autoload mk4
autoload clean_tex_aux_files
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

# bibtex (prefix='e') {{{3
alias ebib="nvim $HOME/Library/texmf/bibtex/bib/my_library.bib"

# Git (prefix='eg') {{{3
alias egc="nvim $XDG_CONFIG_HOME/git/config"
alias egi="nvim $XDG_CONFIG_HOME/git/ignore"
alias egfd="nvim $XDG_CONFIG_HOME/git/filter-repo/dotfiles"
alias egfv="nvim $XDG_CONFIG_HOME/git/filter-repo/vimtex_my_complete"

# kitty (prefix='e') {{{3
alias ek="nvim $XDG_CONFIG_HOME/kitty/kitty.conf"

# latexmk (prefix='e') {{{3
alias elmk="nvim $XDG_CONFIG_HOME/latexmk/latexmkrc"

# make4ht (prefix='e') {{{3
alias emk4="nvim $XDG_CONFIG_HOME/make4ht/config.lua"

# Neovim (prefix='e') {{{3

alias ev="nvim $XDG_CONFIG_HOME/nvim/init.vim"

# notes.vim (prefix='en') {{{4
alias enz="nvim $XDG_CONFIG_HOME/nvim/after/ftplugin/markdown/notes.vim"
alias ena="nvim $XDG_CONFIG_HOME/nvim/autoload/notes.vim"
alias enc="nvim $XDG_CONFIG_HOME/nvim/autoload/notes/complete.vim"
alias eny="nvim $XDG_CONFIG_HOME/nvim/autoload/notes/fzf.vim"
alias enl="nvim $XDG_CONFIG_HOME/nvim/autoload/notes/link.vim"
alias enu="nvim $XDG_CONFIG_HOME/nvim/autoload/notes/u.vim"
alias enf="nvim $XDG_CONFIG_HOME/nvim/ftplugin/markdown/notes.vim"
alias enp="nvim $XDG_CONFIG_HOME/nvim/plugin/notes.vim"

# fzf.vim (prefix='ef') {{{4
alias efa="nvim $XDG_CONFIG_HOME/nvim/autoload/fzf.vim"

# shell.vim (prefix='es') {{{4
alias esa="nvim $XDG_CONFIG_HOME/nvim/autoload/shell.vim"
alias esp="nvim $XDG_CONFIG_HOME/nvim/plugin/shell.vim"

# lilypond.vim (prefix='el') {{{4
alias elc="nvim $XDG_CONFIG_HOME/nvim/compiler/lilypond.vim"
alias elf="nvim $XDG_CONFIG_HOME/nvim/ftplugin/lilypond.vim"
alias elp="nvim $XDG_CONFIG_HOME/nvim/plugin/lilypond.vim"

# help.vim (prefix='eh') {{{4
alias ehf="nvim $XDG_CONFIG_HOME/nvim/ftplugin/help.vim"

# tex.vim (prefix='et') {{{4
alias etf="nvim $XDG_CONFIG_HOME/nvim/ftplugin/tex.vim"

# Spell (prefix='ewl') {{{4
alias ewld="nvim $XDG_CONFIG_HOME/nvim/spell/de.utf-8.add"
alias ewle="nvim $XDG_CONFIG_HOME/nvim/spell/en.utf-8.add"

# mdview.vim (prefix='em') {{{4
alias ema="nvim $XDG_DATA_HOME/nvim/site/autoload/mdview.vim"
alias emc="nvim $XDG_DATA_HOME/nvim/site/autoload/mdview/compiler.vim"
alias emd="nvim $XDG_DATA_HOME/nvim/site/doc/mdview.txt"
alias emf="nvim $XDG_DATA_HOME/nvim/site/ftplugin/markdown/mdview.vim"

# enumerate.vim (previx='ee') {{{4
alias eea="nvim $XDG_DATA_HOME/nvim/site/autoload/enumerate.vim"
alias eem="nvim $XDG_DATA_HOME/nvim/site/autoload/enumerate/motion.vim"
alias eeo="nvim $XDG_DATA_HOME/nvim/site/autoload/enumerate/object.vim"
alias eep="nvim $XDG_DATA_HOME/nvim/site/plugin/enumerate.vim"

# rfv.vim (prefix='er') {{{4
alias erp="nvim $XDG_DATA_HOME/nvim/site/plugin/rfv.vim"
# }}}4

# LaTeX (prefix='et') {{{3
alias et4="nvim $HOME/Library/texmf/tex/latex/tex4ht/tex4ht.cfg"
alias eta="nvim $HOME/Library/texmf/tex/latex/aristotelis/aristotelis.sty"
alias etc="nvim $HOME/Library/texmf/tex/latex/rheldercv/rheldercv.cls"
alias etd="nvim $HOME/Library/texmf/texdoc/texdoc.cnf"
alias eth="nvim \
        $HOME/Library/texmf/tex/latex/rhelderhandout/rhelderhandout.cls"
alias ets="nvim $HOME/Library/texmf/tex/latex/rhelder/rhelder.sty"
alias ety="nvim \
        $HOME/Library/texmf/tex/latex/rheldersyllabus/rheldersyllabus.cls"

# tex4ht (prefix='et4') {{{3
alias et4y="nvim $HOME/Library/texmf/tex/generic/tex4ht/rheldersyllabus.4ht"

# zsh (prefix='e') {{{3
alias ez="nvim $XDG_CONFIG_HOME/zsh/.zshrc"
alias epz="nvim $XDG_CONFIG_HOME/zsh/.zprofile"
alias ehz="nvim $HISTFILE"
# }}}3

# Navigate {{{2
alias b="cd $HOME/.local/bin"
alias -f dc="cd $HOME/Documents"
alias dg="cd $HOME/Documents/Git"
alias dm="cd $HOME/Documents/Personal/LilyPond"
alias dn="cd $HOME/Documents/Notes"
alias -f nc="cd $XDG_CONFIG_HOME/nvim"
alias nd="cd $XDG_DATA_HOME/nvim/site"
alias nr='cd /opt/homebrew/Cellar/neovim/0.10.1/share/nvim/runtime'
alias pc="cd $XDG_DATA_HOME/pandoc/custom"
alias pd="cd $XDG_DATA_HOME/pandoc/defaults"
alias pm="cd $XDG_DATA_HOME/pandoc/metadata"
alias pt="cd $XDG_DATA_HOME/pandoc/templates"
alias py="cd $XDG_DATA_HOME/pandoc/styles"
alias tmf="cs $HOME/Library/texmf"
alias uc="cd $HOME/Documents/Past/2019-2024_UCBerkeley"
alias vm="cd $XDG_CONFIG_HOME/nvim/vimtex_my_complete"
alias vt="cd $XDG_DATA_HOME/nvim/plugged/vimtex"
alias xc="cd $XDG_CONFIG_HOME"
alias xd="cd $XDG_DATA_HOME"
alias zf="cd $XDG_DATA_HOME/zsh/functions"

# Git {{{2
alias -f git='hub'
alias ga='git add'
alias gbD='git branch -D'
alias gbd='git branch -d'
alias gbl='git branch --list'
alias gc='git commit'
alias gd='git diff'
alias gds='git diff --staged'
alias gg='git grep'
alias gl='git log --pretty=short'
alias glg='git log --graph'
alias gll='git log'
alias gpo='git pull origin'
alias gpom='git pull origin main'
alias gpuo='git push -u origin'
alias gpuom='git push -u origin main'
alias gr='git reset'
alias -f gs='git status'
alias gsh='git show'
alias gsmu='git submodule update --remote --merge'
alias gst='git stash'
alias gstp='git stash pop'
alias gsw='git switch'
alias gswc='git switch -c'

# Abbreviate {{{2
alias dgpg='default_gpg'
alias dtar='default_tar'
alias j="jobs"
alias kv="kpsewhich_nvim"
alias la='ls -aF'
alias -f ld='lilydoc'
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
alias sz="source $XDG_CONFIG_HOME/zsh/.zshrc"
alias td='texdoc'
alias ts='trash'
alias vc="ts $XDG_CACHE_HOME/vimtex/pkgcomplete.json"
# }}}2

# Shell variables {{{1

# Files {{{2

# bibtex {{{3
bib="$HOME/Library/texmf/bibtex/bib/my_library.bib"

# Git {{{3
gc="$XDG_CONFIG_HOME/git/config"
gi="$XDG_CONFIG_HOME/git/ignore"
gfd="$XDG_CONFIG_HOME/git/filter-repo/dotfiles"
gfv="$XDG_CONFIG_HOME/git/filter-repo/vimtex_my_complete"

# kitty {{{3
k="$XDG_CONFIG_HOME/kitty/kitty.conf"

# latexmk {{{3
lmk="$XDG_CONFIG_HOME/latexmk/latexmkrc"

# make4ht {{{3
mk4="$XDG_CONFIG_HOME/make4ht/config.lua"

# Neovim {{{3

v="$XDG_CONFIG_HOME/nvim/init.vim"
zv="$XDG_CONFIG_HOME/nvim/zshrc.vim"

# notes.vim {{{4
nz="$XDG_CONFIG_HOME/nvim/after/ftplugin/markdown/notes.vim"
na="$XDG_CONFIG_HOME/nvim/autoload/notes.vim"
nc="$XDG_CONFIG_HOME/nvim/autoload/notes/complete.vim"
ny="$XDG_CONFIG_HOME/nvim/autoload/notes/fzf.vim"
nl="$XDG_CONFIG_HOME/nvim/autoload/notes/link.vim"
nu="$XDG_CONFIG_HOME/nvim/autoload/notes/u.vim"
nf="$XDG_CONFIG_HOME/nvim/ftplugin/markdown/notes.vim"
np="$XDG_CONFIG_HOME/nvim/plugin/notes.vim"

# fzf.vim {{{4
fa="$XDG_CONFIG_HOME/nvim/autoload/fzf.vim"

# shell.vim {{{4
sa="$XDG_CONFIG_HOME/nvim/autoload/shell.vim"
sp="$XDG_CONFIG_HOME/nvim/plugin/shell.vim"

# lilypond.vim {{{4
lc="$XDG_CONFIG_HOME/nvim/compiler/lilypond.vim"
lf="$XDG_CONFIG_HOME/nvim/ftplugin/lilypond.vim"
lp="$XDG_CONFIG_HOME/nvim/plugin/lilypond.vim"

# help.vim {{{4
hf="$XDG_CONFIG_HOME/nvim/ftplugin/help.vim"

# tex.vim {{{4
tf="$XDG_CONFIG_HOME/nvim/ftplugin/tex.vim"

# Spell {{{4
wld="$XDG_CONFIG_HOME/nvim/spell/de.utf-8.add"
wle="$XDG_CONFIG_HOME/nvim/spell/en.utf-8.add"

# mdview.vim {{{4
ma="$XDG_DATA_HOME/nvim/site/autoload/mdview.vim"
mc="$XDG_DATA_HOME/nvim/site/autoload/mdview/compiler.vim"
md="$XDG_DATA_HOME/nvim/site/doc/mdview.txt"
mf="$XDG_DATA_HOME/nvim/site/ftplugin/markdown/mdview.vim"

# enumerate.vim {{{4
ea="$XDG_DATA_HOME/nvim/site/autoload/enumerate.vim"
em="$XDG_DATA_HOME/nvim/site/autoload/enumerate/motion.vim"
eo="$XDG_DATA_HOME/nvim/site/autoload/enumerate/object.vim"
ep="$XDG_DATA_HOME/nvim/site/plugin/enumerate.vim"

# rfv.vim {{{4
rp="$XDG_DATA_HOME/nvim/site/plugin/rfv.vim"
# }}}4

# LaTeX {{{3
t4="$HOME/Library/texmf/tex/latex/tex4ht/tex4ht.cfg"
ta="$HOME/Library/texmf/tex/latex/aristotelis/aristotelis.sty"
tc="$HOME/Library/texmf/tex/latex/rheldercv/rheldercv.cls"
td="$HOME/Library/texmf/texdoc/texdoc.cnf"
th="$HOME/Library/texmf/tex/latex/rhelderhandout/rhelderhandout.cls"
ts="$HOME/Library/texmf/tex/latex/rhelder/rhelder.sty"
ty="$HOME/Library/texmf/tex/latex/rheldersyllabus/rheldersyllabus.cls"

# tex4ht {{{3
t4y="$HOME/Library/texmf/tex/generic/tex4ht/rheldersyllabus.4ht"

# zsh {{{3
z="$XDG_CONFIG_HOME/zsh/.zshrc"
pr="$XDG_CONFIG_HOME/zsh/.zprofile"
hf="$HISTFILE"
# }}}3

# Directories {{{2
b="$HOME/.local/bin"
dc="$HOME/Documents"
dg="$HOME/Documents/Git"
dm="$HOME/Documents/Personal/LilyPond"
dn="$HOME/Documents/Notes"
nc="$XDG_CONFIG_HOME/nvim"
nd="$XDG_DATA_HOME/nvim/site"
nr='/opt/homebrew/Cellar/neovim/0.10.1/share/nvim/runtime'
pc="$XDG_DATA_HOME/pandoc/custom"
pd="$XDG_DATA_HOME/pandoc/defaults"
pm="$XDG_DATA_HOME/pandoc/metadata"
pt="$XDG_DATA_HOME/pandoc/templates"
py="$XDG_DATA_HOME/pandoc/styles"
tmf="$HOME/Library/texmf"
uc="$HOME/Documents/Past/2019-2024_UCBerkeley"
vm="$XDG_CONFIG_HOME/nvim/vimtex_my_complete"
vt="$XDG_DATA_HOME/nvim/plugged/vimtex"
xc="$XDG_CONFIG_HOME"
xd="$XDG_DATA_HOME"
zf="$XDG_DATA_HOME/zsh/functions"
# }}}2

# }}}1
