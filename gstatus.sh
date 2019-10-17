#!/bin/sh

# gstatus - An eye candy git status script.

# Gives the current branch.
function git_current_branch {
    git rev-parse --symbolic-full-name --abbrev-ref HEAD --sq
}

# Gives the upstream branch.
function git_upstream_branch {
    git rev-parse --symbolic-full-name --abbrev-ref HEAD@{u} &>/dev/null
    if [ $? -eq 0 ] ; then
        git rev-parse --symbolic-full-name --abbrev-ref HEAD@{u} --sq
    fi
}

# Find remotes with the same branch.
function git_remote_branches {
    current=$(git_current_branch)
    for i in $(git branch -r) ; do
        if [[ $i == *$current ]] ; then
            echo $i
        fi
    done
}

# Gives the number of commit ahead from upstream.
# $1 string Remote to check.
function git_diff_ahead {
    git cherry -v $1 | wc -l
}

# Gives the number of commit behind upstream.
# $1 string Remote to check.
function git_diff_behind {
    git log HEAD..$1 --oneline | wc -l
}

# Print the branching status for a given remote.
function branching_status {
    # f126 is the unicone character for git branch icon from Font Awesome
    printf " \033[0;33m\uf126 $1"

    # diff
    # Font Awesome icons :
    #   f0fe=plus-square ; f146=minus-square ; f14a=check-square ;
    #   ufd3= times-square
    #   f055=plus-circle ; f056=minus-cicle ; f058=check-square ;
    #   f057=times-circle
    add=$(git_diff_ahead $1)
    sub=$(git_diff_behind $1)

    printf ' '
    # [ $add != 0 ] && [ $sub != 0 ] && printf "\033[0m \033[0;33m\uf057 : "
    [ $add != 0 ] && printf "\033[0m\033[0;32m\uf055 $add"
    [ $sub != 0 ] && printf "\033[0m\033[0;31m\uf056 $sub"
    [[ $add == 0 && $sub == 0 ]] && printf "\033[0;34m\uf058"
}

# Give a string with the current braching status :
# [BRANCH] I [UPSTREAM] [DIFF]
#     BRANCH : (bold blue) the current branch
#     I : (yellow) a nice branch icon from Font Awesome
#     UPSTREAM : (italic yellow) The upstream branch
#     DIFF : Diff with upstream (show icons and commits count behind/ahead or
#       a OK symbol if aligned)
function git_branching_status {
    printf "\033[1;34m$(git_current_branch)"

    upstream=$(git_upstream_branch)
    if [[ -n $upstream ]] ; then
        branching_status $upstream
    fi

    for i in $(git_remote_branches) ; do
        if [[ $i == $upstream ]] ; then continue; fi
        printf ' |'
        branching_status $i
    done

    # standard formating + chariage return at EOL ;)
    printf '\033[0;00m\n'
}

# Give a short git status
function git_status {
    git status -s -unormal --column
}

# Give a quick overview of git stash
function git_stash_status {
    git stash list
}

git_branching_status
git_status
git_stash_status
