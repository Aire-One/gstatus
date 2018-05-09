#!/bin/bash

# This script aims to display a nice git status.
# It will give a colored and easy to read quick overview of the current status.
#
# No args for now, maybe some shortcuts in the future o/


function git-current-branch {
    git rev-parse --symbolic-full-name --abbrev-ref HEAD --sq
}

function git-upstream-branch {
    git rev-parse --symbolic-full-name --abbrev-ref HEAD@{u} &>/dev/null
    if [ $? -eq 0 ] ; then
        git rev-parse --symbolic-full-name --abbrev-ref HEAD@{u} --sq
    fi
}

function git-diff-ahead {
    git cherry -v | wc -l
}

function git-diff-behind {
    git log HEAD..$(git-upstream-branch) --oneline | wc -l
}

# Give a string with the current braching status :
# [BRANCH] I [UPSTREAM] [DIFF]
#     BRANCH : (bold blue) the current branch
#     I : (yellow) a nice branch icon from Font Awesome
#     UPSTREAM : (italic yellow) The upstream branch
#     DIFF : Diff with upstream (show icons and commits count behind/ahead or
#       a OK symbol if aligned)
function branching-status {
    printf "\033[1;34m$(git-current-branch)"

    upstream=$(git-upstream-branch)

    if [[ -n $upstream ]] ; then
        # f126 is the unicone character for git branch icon from Font Awesome
        printf '\033[0;33m \uf126 '

        printf "\033[3;33m$upstream"

        # diff
        # Font Awesome icons :
        #   f0fe=plus-square ; f146=minus-square ; f14a=check-square ;
        #   ufd3= times-square
        add=$(git-diff-ahead)
        sub=$(git-diff-behind)

        printf " "
        # [ $add != 0 ] && [ $sub != 0 ] && printf "\033[0m \033[0;33m\uf2d3 : "
        [ $add != 0 ] && printf "\033[0m\033[0;32m\uf0fe $add "
        [ $sub != 0 ] && printf "\033[0m\033[0;31m\uf146 $sub "
        [[ $add == 0 && $sub == 0 ]] && printf ' \033[0;34m\uf14a'
    fi

    # standard formating + chariage return at EOL ;)
    printf '\033[0;00m\n'
}

# Give a short git status
function git-status {
    git status -s -unormal --column
}

# Give a quick overview of git stash
function git-stash-status {
    git stash list
}

branching-status
git-status
git-stash-status

