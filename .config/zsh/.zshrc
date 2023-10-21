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

autoload $XDG_DATA_HOME/zsh/functions/[^_]*(:t)

# {{{1 Aliases

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
alias o='open'
alias pd="cd $XDG_DATA_HOME/pandoc"
alias pdd="cd $XDG_DATA_HOME/pandoc/defaults"
alias pdt="cd $XDG_DATA_HOME/pandoc/templates"
alias restart='unset FPATH && PATH=/bin && exec -l zsh'
alias sz="source $XDG_CONFIG_HOME/zsh/.zshrc"
alias szp="source $XDG_CONFIG_HOME/zsh/.zprofile"
alias ucb="cd $HOME/Documents/UCBerkeley"
alias vcc="ts $XDG_CACHE_HOME/vimtex/pkgcomplete.json"
alias vmc="cd $XDG_CONFIG_HOME/nvim/vimtex_my_complete"
alias vtc="cd $XDG_DATA_HOME/nvim/plugged/vimtex/autoload/vimtex/complete"
alias xch="cd $XDG_CONFIG_HOME"
alias xdh="cd $XDG_DATA_HOME"
alias zf="cd $XDG_DATA_HOME/zsh/functions"

# {{{1 Shell variables

a=$HOME/Library/texmf/tex/latex/aristotelis/aristotelis.sty
df=$XDG_CONFIG_HOME/git/filter-repo/dotfiles
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

# Filter my private repo and push the filtered repo to a new remote (e.g., for
# publishing part of my private repo as a public repo)
function github-publish {
     trap 'return 1' ERR
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
     git filter-repo --paths-from-file $XDG_CONFIG_HOME/git/filter-repo/$1

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

# Create Zotero storage library and rename directories and files in accordance
# with bibtex key

typeset -A shorttitles
shorttitles=( \
    [Bonitz]='bonitz 1955 Index Aristotelicus' \
    [LSJ]='liddell Scott 1940 Greek English Lexicon' \
    [Smyth]='smyth 1956 Greek Grammar' \
    [TLG]='2014 TLG Home' \
    [APo]='aristotle 1964 Analytica Posteriora' \
    [APr]='aristotle 1964 Analytica Priora' \
    [CGCG]='van Emde Boas 2019 Cambridge Grammar' \
    [DA]='aristotle 1964 De Anima' \
    [EE]='aristotle 1991 Ethica Eudemia' \
    [EN]='aristotle 1894 Ethica Nicomachea' \
    [MA]='aristotle 2020 De Motu Animalium' \
    [Met]='aristotle 1957 Metaphysica' \
    [Phys]='aristotle 1950 Physica' \
    [Pol]='aristotle 1957 Politica' \
    [Top]='aristotle 1958 Topica sophistici' \
    )

function zotero-storage {
    trap 'return 1' ERR

    local wd=$(pwd)
    cd $HOME/Documents/Zotero/Storage

    # Clean up empty subdirectories
    echo 'Cleaning up empty subdirectories...'
    local dir
    local subdir
    for dir in *(/); do
        if [[ $(ls -F $dir | rg /) ]]; then
            cd $dir
            for subdir in *(/); do
                if [[ ! $(ls $subdir) ]]; then
                    rmdir $subdir
                fi
            done
            cd ..
        fi
    done

    echo 'Making directories for new entries,' \
        'checking for PDFs in Zotero' \
        'storage, and renaming files...' \
        | fmt -79

    # Parse `bib` file
    local item
    for item in $(rg '^@.+\{(.+?)\.*,$' --replace '$1' -- \
        $HOME/Library/texmf/bibtex/bib/myLibrary.bib); do

        if [[ $(pwd) != $HOME/Documents/Zotero/Storage ]]; then
            echo 'Error: not in Zotero storage directory'
            return 1
        fi

        # If directory corresponding to `bib` entry doesn't exist, make it
        # (along with two default subdirectories, 'annotated' and 'clean', for
        # convenience)
        if [[ ! -d $item ]]; then
            mkdir $item
            mkdir $item/clean
            mkdir $item/annotated
        fi

        # Check for pdf in Zotero storage cd $HOME/Zotero/storage
        cd $HOME/Zotero/storage
        # If the item in question has a short title, then use the value from
        # the `shorttitles` associative array; otherwise, split up the
        # `biblatex` key and use that
        if [[ $shorttitles[$item] ]]; then
            local query=$shorttitles[$item]
        else
            local query=$(echo $item | \
                sed -E 's/([0-9]{4})/ \1 /' | \
                sed -E 's/([A-Z])/ \1/g')
        fi
        trap -
        local match=$(fd --type f --strip-cwd-prefix | fzf -i -f "$query")
        trap 'return' ERR
        if [[ $match ]]; then
            local REPLY
            if (( $( (){echo $#} ${(f)match} ) > 1 )); then
                local pdfs=(${(f)match})
                echo ${#pdfs[@]} 'PDFs were found in Zotero''s storage:'
                local pdf
                for pdf in $pdfs; do
                    echo ${pdf#*/}
                done
                for pdf in $pdfs; do
                    read "?Copy '${pdf#*/}' to ~/Zotero/Storage? (y/n) "
                    if [[ $REPLY == y || $REPLY == Y ]]; then
                        cp $HOME/Zotero/storage/$pdf \
                            $HOME/Documents/Zotero/Storage/$item/${pdf/\//_}
                        echo File copied.
                    else
                        echo File not copied.
                    fi
                done
            else
                echo '1 PDF was found in Zotero storage:'
                echo ${match#*/}
                read "?Copy '${match#*/}'? (y/n) "
                if [[ $REPLY == y || $REPLY == Y ]]; then
                    cp $HOME/Zotero/storage/$match \
                        $HOME/Documents/Zotero/Storage/$item/${match/\//_}
                    echo File copied.
                else
                    echo File not copied.
                fi
            fi
        fi
        cd - > /dev/null

        if [[ $(pwd) != $HOME/Documents/Zotero/Storage ]]; then
            echo 'Error: not in Zotero storage directory'
            return 1
        fi

        # If the directory is non-empty, enter the directory
        if [[ $(ls $item) ]]; then
            cd $item
            # If the directory contains files, rename the files after the
            # directory
            local file
            if [[ $(ls -F | rg -v /) ]]; then
                for file in *(.); do
                    mv $file ${file/*./$item.}
                done
            fi

            # If the directory contains subdirectories, and they are non-empty,
            # enter the subdirectories and rename the files after the directory
            # and the subdirectory together
            if [[ $(ls -F | rg /) ]]; then
                for subdir in *(/); do
                    if [[ $(ls $subdir) ]]; then
                        cd $subdir
                        for file in *(.); do
                            mv $file ${file/*./$item\_$subdir.}
                        done
                        cd ..
                    fi
                done
            fi
            cd ..
        fi
    done

    # Check that storage directory and Zotero library are in sync
    echo 'Checking that storage directory and Zotero library are in sync...'
    if [[ $(comm -23 \
        =(rg '^@.+\{(.+?)\.*,$' --replace '$1' -- $bib | sort) \
        =(ls | sort)) \
        ]]; then
        echo 'Unknown error occured:' \
            'storage directory and Zotero library not in sync' \
            fmt -79
    else local del=$(comm -13 \
        =(rg '^@.+\{(.+?)\.*,$' --replace '$1' -- $bib | sort) \
        =(ls | sort))
        if [[ $del ]]; then
            echo 'The following items are not in your Zotero library:'
            echo $del
        fi
    fi

    cd $wd
    echo 'Done.'
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
