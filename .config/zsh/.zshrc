# to-do
# * `zotero-storage`: turn `match` and `query` into arrays
# * Consider adding check to `zotero-storage` if any PDFs weren't copied
# * Add more tar- and gpg-related functions
# * Turn remaining functions into scripts
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

autoload alias
autoload cs
autoload mktar
autoload mz
autoload nvim-help
autoload trash
autoload untar


# {{{1 Aliases

alias bin="cd $HOME/.local/bin"
alias Cl="ts ^*.(((tex)|(latex)|(sty)|(bib)|(txt)|(md)|(vim)))(.)"
alias cl="ts ^*.(((tex)|(latex)|(sty)|(bib)|(txt)|(md)|(vim)|(pdf)))(.)"
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
alias es="nvim $HOME/Library/texmf/tex/latex/rhelder/rhelder.sty"
alias espd="nvim $XDG_CONFIG_HOME/nvim/spell/de.utf-8.add"
alias espe="nvim $XDG_CONFIG_HOME/nvim/spell/en.utf-8.add"
alias ev="nvim $XDG_CONFIG_HOME/nvim/init.vim"
alias ez="nvim $XDG_CONFIG_HOME/zsh/.zshrc"
alias ezh="nvim $HISTFILE"
alias ezp="nvim $XDG_CONFIG_HOME/zsh/.zprofile"
alias ga='git add'
alias gbd='git branch -d'
alias gbD='git branch -D'
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
alias nv='nvim'
alias nvh='nvim-help'
alias o='open'
alias pd="cd $XDG_DATA_HOME/pandoc"
alias pdd="cd $XDG_DATA_HOME/pandoc/defaults"
alias pdt="cd $XDG_DATA_HOME/pandoc/templates"
alias restart='unset FPATH && PATH=/bin && exec -l zsh'
alias sz="source $XDG_CONFIG_HOME/zsh/.zshrc"
alias szp="source $XDG_CONFIG_HOME/zsh/.zprofile"
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
s=$HOME/Library/texmf/tex/latex/rhelder/rhelder.sty
spd=$XDG_CONFIG_HOME/nvim/spell/de.utf-8.add
spe=$XDG_CONFIG_HOME/nvim/spell/en.utf-8.add
v=$XDG_CONFIG_HOME/nvim/init.vim
xch=$XDG_CONFIG_HOME
xdh=$XDG_DATA_HOME
z=$XDG_CONFIG_HOME/zsh/.zshrc
zf=$XDG_DATA_HOME/zsh/functions
zp=$XDG_CONFIG_HOME/zsh/.zprofile

# {{{1 Functions

# Open new note
function nn {
    nvim -c 'let name = strftime("%Y%m%d%H%M%S")' \
        -c 'cd ~/Documents/Notes' \
        -c 'execute "edit " .. name .. ".md"' \
        -c 'execute "normal i---\r---\<Esc>"' \
        -c 'execute "normal Okeywords: \<Esc>"' \
        -c 'execute "normal Otitle: \<Esc>"' \
        -c 'execute "normal Oid: " .. name .. "\<Esc>"'
}

# Open new journal entry
function nj {
    cd $HOME/Documents/Notes
    if [[ -f $(date "+%F").txt ]]; then
        nvim $(date "+%F").txt
    else
        nvim -c 'execute "edit " .. strftime("%F") .. ".txt"' \
            -c 'execute "normal i" .. strftime("%A, %B %e, %Y") .. "\<Esc>"'
    fi
    cd - > /dev/null
}

# Clone my `vimtex_my_complete` repository into VimTeX's completion file
# directory
function vmc-clone {
     trap 'return 1' ERR

     echo Cloning:
     cd $XDG_DATA_HOME/nvim/plugged/vimtex/autoload/vimtex/complete
     git clone https://github.com/rhelder/vimtex_my_complete.git
     cd vimtex_my_complete

     echo Filtering:
     if [[ $(pwd) != $XDG_DATA_HOME/nvim/plugged/vimtex/autoload/vimtex/complete/vimtex_my_complete ]]; then
          echo Error: proceeding might rewrite the history of another repository \
               because you are in the wrong directory
          return 1
     fi
     git filter-repo --invert-paths --path README.md --path texstudio_my_cwls

     echo Unpacking:
     cd ..
     if [[ $(pwd) != $XDG_DATA_HOME/nvim/plugged/vimtex/autoload/vimtex/complete ]]; then
          echo Error: obsolete .git directory cannot be deleted and replaced \
               because you are in the wrong directory
          return 1
     fi
     [[ -d .git ]] && sudo rm -r .git
     mv vimtex_my_complete/(.*|*) .

     echo Cleaning up:
     rmdir vimtex_my_complete
}

# Install run-help
if [[ $(alias -m run-help) != '' ]]
     then unalias run-help
fi
autoload -Uz run-help
autoload -Uz run-help-git
# Set Neovim as pager for run-help
# functions -c run-help run-help-def
# function run-help {
#      local HELPDIR='/usr/share/zsh/5.9/help'
#      local PAGER='nvim +silent!Man!'
#      run-help-def $*
# }
local HELPDIR='/usr/share/zsh/5.9/help'

# }}}1
