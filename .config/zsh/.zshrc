# to-do
# * Consider completion options

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

# Configure `rfv`
export RFV_DEFAULT_BIND='--bind=enter:become(nvim {1} +{2})'
export -T RFV_DEFAULT_ADDITIONAL_OPTIONS rfv_default_additional_options '@'
rfv_default_additional_options=(
    --bind='ctrl-o:become(md-open {1})'
)

# {{{1 Functions

# Use `autoload` and `alias` functions instead of builtins

integer autoload_zshrc_sourced=0
if [[ $(whence -w autoload) == 'autoload: function' ]]; then
    autoload -f autoload
else
    autoload autoload
fi

integer alias_zshrc_sourced=0
autoload -f alias

# Load other user functions
autoload clean_tex_aux_files
autoload cs
autoload default_gpg
autoload default_tar
autoload man_zsh
autoload nvim_help
autoload trash

# Install run-help
[[ ${"$(whence -w run-help)"##*: } == 'alias' ]] && unalias run-help
autoload -Uz run-help
autoload -Uz run-help-git
export HELPDIR='/usr/share/zsh/5.9/help'

# {{{1 Aliases

# {{{2 Edit
alias eas="nvim $HOME/Library/texmf/tex/latex/aristotelis/aristotelis.sty"
alias ebgt="open $HOME/Documents/Personal/Finance/budget_2023.xlsx"
alias ebib="nvim $HOME/Library/texmf/bibtex/bib/my_library.bib"
alias ecv="nvim $HOME/Library/texmf/tex/latex/rhelder-cvcls/rhelder-cv.cls"
alias edf="nvim $XDG_CONFIG_HOME/git/filter-repo/dotfiles"
alias efzf="nvim $XDG_CONFIG_HOME/fzf/fzf.zsh"
alias egc="nvim $XDG_CONFIG_HOME/git/config"
alias egi="nvim $XDG_CONFIG_HOME/git/ignore"
alias ehf="nvim $HISTFILE"
alias elmk="nvim $XDG_CONFIG_HOME/latexmk/latexmkrc"
alias emva="nvim $XDG_DATA_HOME/nvim/site/autoload/mdview.vim"
alias emvd="nvim $XDG_DATA_HOME/nvim/site/doc/mdview.txt"
alias emvf="nvim $XDG_DATA_HOME/nvim/site/ftplugin/markdown/mdview.vim"
alias emvz="nvim $XDG_DATA_HOME/nvim/site/after/ftplugin/markdown/mdview.vim"
alias emz="nvim $XDG_CONFIG_HOME/nvim/after/ftplugin/markdown.vim"
alias ena="nvim $XDG_CONFIG_HOME/nvim/autoload/notes.vim"
alias enf="nvim $XDG_CONFIG_HOME/nvim/ftplugin/markdown/notes.vim"
alias enp="nvim $XDG_CONFIG_HOME/nvim/plugin/notes.vim"
alias epr="nvim $XDG_CONFIG_HOME/zsh/.zprofile"
alias erfv="nvim $XDG_DATA_HOME/nvim/site/plugin/rfv.vim"
alias es="nvim $HOME/Library/texmf/tex/latex/rhelder/rhelder.sty"
alias etd="nvim $HOME/Library/texmf/texdoc/texdoc.cnf"
alias ev="nvim $XDG_CONFIG_HOME/nvim/init.vim"
alias ewld="nvim $XDG_CONFIG_HOME/nvim/spell/de.utf-8.add"
alias ewle="nvim $XDG_CONFIG_HOME/nvim/spell/en.utf-8.add"
alias ez="nvim $XDG_CONFIG_HOME/zsh/.zshrc"

# {{{2 Navigate
alias b="cd $HOME/.local/bin"
alias doc="cd $HOME/Documents"
alias docg="cd $HOME/Documents/Git"
alias nd="cd $HOME/Documents/Notes"
alias ndh="cd $XDG_DATA_HOME/nvim/site"
alias pdd="cd $XDG_DATA_HOME/pandoc/defaults"
alias pdt="cd $XDG_DATA_HOME/pandoc/templates"
alias ucb="cd $HOME/Documents/Past/2019-2024_UCBerkeley"
alias vcc="ts $XDG_CACHE_HOME/vimtex/pkgcomplete.json"
alias vmc="cd $XDG_CONFIG_HOME/nvim/vimtex_my_complete"
alias vtc="cd $XDG_DATA_HOME/nvim/plugged/vimtex/autoload/vimtex/complete"
alias xch="cd $XDG_CONFIG_HOME"
alias xdh="cd $XDG_DATA_HOME"
alias zf="cd $XDG_DATA_HOME/zsh/functions"

# {{{2 Git
alias ga='git add'
alias gbD='git branch -D'
alias gbd='git branch -d'
alias gbl='git branch --list'
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

# {{{2 Abbreviate
alias cl='clean_tex_aux_files'
alias dgpg='default_gpg'
alias dtar='default_tar'
alias la='ls -aF'
alias lua='luajit'
alias m='man'
alias mz='man_zsh'
alias ne='edit-recent-note'
alias ni='browse-index'
alias nj='new-journal'
alias nn='new-note'
alias ns='search-notes'
alias nv='nvim'
alias nvh='nvim_help'
alias o='open'
alias restart='[[ $(jobs) ]] && unset FPATH && PATH=/bin && exec -l zsh'
alias spr="source $XDG_CONFIG_HOME/zsh/.zprofile"
alias sz="source $XDG_CONFIG_HOME/zsh/.zshrc"
alias td='texdoc'
alias ts='trash'
# }}}2

# {{{1 Shell variables

declare as="$HOME/Library/texmf/tex/latex/aristotelis/aristotelis.sty"
declare b="$HOME/.local/bin"
declare bib="$HOME/Library/texmf/bibtex/bib/my_library.bib"
declare cv="$HOME/Library/texmf/tex/latex/rhelder-cvcls/rhelder-cv.cls"
declare df="$XDG_CONFIG_HOME/git/filter-repo/dotfiles"
declare doc="$HOME/Documents"
declare docg="$HOME/Documents/Git"
declare fzf="$XDG_CONFIG_HOME/fzf/fzf.zsh"
declare gc="$XDG_CONFIG_HOME/git/config"
declare gi="$XDG_CONFIG_HOME/git/ignore"
declare lmk="$XDG_CONFIG_HOME/latexmk/latexmkrc"
declare mva="$XDG_DATA_HOME/nvim/site/autoload/mdview.vim"
declare mvd="$XDG_DATA_HOME/nvim/site/doc/mdview.txt"
declare mvp="$XDG_DATA_HOME/nvim/site/ftplugin/markdown/mdview.vim"
declare mvz="$XDG_DATA_HOME/nvim/site/after/ftplugin/markdown/mdview.vim"
declare mz="$XDG_CONFIG_HOME/nvim/after/ftplugin/markdown.vim"
declare na="$XDG_CONFIG_HOME/nvim/autoload/notes.vim"
declare nd="$HOME/Documents/Notes"
declare ndh="$XDG_DATA_HOME/nvim/site"
declare nf="$XDG_CONFIG_HOME/nvim/ftplugin/markdown/notes.vim"
declare np="$XDG_CONFIG_HOME/nvim/plugin/notes.vim"
declare nt="$HOME/Documents/Notes"
declare pdd="$XDG_DATA_HOME/pandoc/defaults"
declare pdt="$XDG_DATA_HOME/pandoc/templates"
declare pr="$XDG_CONFIG_HOME/zsh/.zprofile"
declare rfv="$XDG_DATA_HOME/nvim/site/plugin/rfv.vim"
declare s="$HOME/Library/texmf/tex/latex/rhelder/rhelder.sty"
declare td="$HOME/Library/texmf/texdoc/texdoc.cnf"
declare ucb="$HOME/Documents/Past/2019-2024_UCBerkeley"
declare v="$XDG_CONFIG_HOME/nvim/init.vim"
declare vmc="$XDG_CONFIG_HOME/nvim/vimtex_my_complete"
declare vtc="$XDG_DATA_HOME/nvim/plugged/vimtex/autoload/vimtex/complete"
declare vz="$XDG_CONFIG_HOME/nvim/zshrc.vim"
declare wld="$XDG_CONFIG_HOME/nvim/spell/de.utf-8.add"
declare wle="$XDG_CONFIG_HOME/nvim/spell/en.utf-8.add"
declare xch="$XDG_CONFIG_HOME"
declare xdh="$XDG_DATA_HOME"
declare z="$XDG_CONFIG_HOME/zsh/.zshrc"
declare zf="$XDG_DATA_HOME/zsh/functions"

# }}}1
