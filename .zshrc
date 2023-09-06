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
vmc="$HOME/.config/nvim/vimtex_my_complete"
vtc="$HOME/.config/nvim/vim-plug/vimtex/autoload/vimtex/complete"
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
alias vmc="cd $HOME/.config/nvim/vimtex_my_complete"
alias vtc="cd $HOME/.config/nvim/vim-plug/vimtex/autoload/vimtex/complete"

# {{{1 Functions

# Execute `cd` and then `ls`
function cs {
     cd $* && ls
}

# Find files to be removed (e.g., when uninstalling an application)
function ffr {
     sudo find / ${*:?Expression required.} -print 2>/dev/null > $HOME/rm_files.txt
}

# Search NeoVim help files from command line
function nvimh {
     nvim -c "help $*" -c "only"
}

# Move a file to Trash
function trash {
     mv ${*:?What you want to move to Trash needs to be specified.} $HOME/.Trash
}

# Extract a `tar` file into a directory of the same name in the parent directory
function untar {
     file=${*:?Tarball must be specified.}
     mkdir ${file%.tar*}
     tar -xf $file -C ${file%.tar*}
}

# Filter my private repo and push the filtered repo to a new remote (e.g., for
# publishing part of my private repo as a public repo)
function github-publish {
     trap 'trap -; return' ERR
     if [[ ! $1 ]]; then
	  echo Error: please enter name of target repository
	  return 1
     elif [[ ! -a $HOME/.github/$1 ]]; then
	  echo Error: $HOME/.github/$1 does not exist
	  return 1
     fi

     echo Cloning:
     local dir=$(pwd)
     git clone https://github.com/rhelder/rhelder.git --recurse-submodules
     cd rhelder

     echo Filtering:
     if [[ $(git rev-parse --show-toplevel) == /Users/rhelder \
	  || $(pwd) != $dir/rhelder ]]; then
	  echo Error: proceeding might rewrite the history of another repository \
	       because you are in the wrong directory
	  return 1
     fi
     git filter-repo --paths-from-file $HOME/.github/$1

     echo Pushing:
     git remote add origin https://github.com/rhelder/$1.git
     git push origin main $2

     echo Cleaning up
     cd ..
     sudo rm -r rhelder
}

# Clone my `vimtex_my_complete` repository into VimTeX's completion file
# directory
function vmc-clone {
     trap 'trap -; return' ERR

     echo Cloning:
     echo $HOME/.config/nvim/vim-plug/vimtex/autoload/vimtex/complete
     cd $HOME/.config/nvim/vim-plug/vimtex/autoload/vimtex/complete
     ls
     git clone https://github.com/rhelder/vimtex_my_complete.git
     cd vimtex_my_complete

     echo Filtering:
     if [[ $(pwd) != $HOME/.config/nvim/vim-plug/vimtex/autoload/vimtex/complete/vimtex_my_complete ]]; then
          echo Error: proceeding might rewrite the history of another repository \
               because you are in the wrong directory
          return 1
     fi
     git filter-repo --invert-paths --path README.md --path texstudio_my_cwls

     echo Unpacking:
     cd ..
     if [[ $(pwd) != $HOME/.config/nvim/vim-plug/vimtex/autoload/vimtex/complete ]]; then
          echo Error: obsolete .git directory cannot be deleted and replaced \
               because you are in the wrong directory
          return 1
     fi
     sudo rm -r .git
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
