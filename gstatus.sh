#!/usr/bin/env sh

# gstatus - An eye candy git status script.

# Configuration:
#
# escape printf builtin that does not necessarly support unicode
alias printf='env printf'

# The following globals variables are used to configure the output of gstatus.
# You can change these string value to whatever you want. Including
# colors/styles/icons/... of your chose.
# The defaults are the values I use. I do use fontawesome and font ligatures,
# so it can be a bit weird if your terminal don't support that.

# Reset.
STYLE_RESET='\e[0;00m'
# Current branch style.
STYLE_CURRENT_BRANCH='\e[1;34m'
# Separator between local and remote branches
SEPARATOR_SECTION_BRANCHES=''
# Separator between remotes branches.
SEPARATOR_BRANCHES_REMOTE=' \e[1;34m||'
# Upstream branch style.
STYLE_UPSTREAM_BRANCHES=' \e[1;33m\uf126 '
# Remote branches style.
STYLE_REMOTES_BRANCHES=' \e[0;33m\uf126 '
# Style for even commits.
STYLE_EVEN_COMMITS=' \e[0;34m\uf058'
# Style for ahead commits.
STYLE_AHEAD_COMMITS=' \e[0m\e[0;32m\uf055'
# Style for behind commits.
STYLE_BEHIND_COMMITS=' \e[0m\e[0;31m\uf056'


# Gives the current branch.
git_current_branch() {
    git rev-parse --symbolic-full-name --abbrev-ref HEAD --sq
}

# Gives the upstream branch.
git_upstream_branch() {
    if git rev-parse --symbolic-full-name --abbrev-ref 'HEAD@{u}' > /dev/null 2>&1; then
        git rev-parse --symbolic-full-name --abbrev-ref 'HEAD@{u}' --sq
    fi
}

# Find remotes with the same branch.
git_remote_branches() {
    current=$(git_current_branch)
    git branch --remotes --list "*${current}"
}

# Gives the number of commit ahead from upstream.
# $1 string Remote to check.
git_diff_ahead() {
    git cherry -v "${1}" | wc -l
}

# Gives the number of commit behind upstream.
# $1 string Remote to check.
git_diff_behind() {
    git log HEAD.."${1}" --oneline | wc -l
}

# Gives the branching status for a given remote.
# $1 string Remote/Branch name.
# $2 string The style to apply to the remote/branch name.
branching_status() {
    # f126 is the unicone character for git branch icon from Font Awesome
    printf '%b%b%s' "${STYLE_RESET}" "${2}" "${1}"

    add=$(git_diff_ahead "${1}")
    sub=$(git_diff_behind "${1}")

    [ "${add}" != 0 ] && printf '%b%b%s' "${STYLE_RESET}" "${STYLE_AHEAD_COMMITS}" "${add}"
    [ "${sub}" != 0 ] && printf '%b%b%s' "${STYLE_RESET}" "${STYLE_BEHIND_COMMITS}" "${sub}"
    [ "${add}" = 0 ] && [ "${sub}" = 0 ] && printf '%b%b' "${STYLE_RESET}" "${STYLE_EVEN_COMMITS}"
}

# Gives the current braching status.
# The output is formated as following:
# [BRANCH] I [UPSTREAM] [DIFF] II [REMOTE] [DIFF]
#     BRANCH : The current local branch name.
#     I        : Separator between the local current and the upstream.
#     UPSTREAM : The upstream branch.
#     DIFF     : Diff with upstream (commits count behind/ahead).
#     II       : Separator between remotes.
#     [REMOTE] : The remote branch.
#     DIFF     : Diff with upstream (commits count behind/ahead).
# Note: The last part (II [REMOTE] [DIFF]) is repeated for each remotes we find.
git_branching_status() {
    current=$(git_current_branch)

    printf '%b%b%s' "${STYLE_RESET}" "${STYLE_CURRENT_BRANCH}" "${current}"
    printf '%b%b' "${STYLE_RESET}" "${SEPARATOR_SECTION_BRANCHES}"

    upstream=$(git_upstream_branch)
    if [ -n "$upstream" ] ; then
        branching_status "${upstream}" "${STYLE_UPSTREAM_BRANCHES}"
    fi

    for i in $(git branch --remotes --list "*${current}") ; do
        if [ "${i}" = "${upstream}" ] ; then continue; fi
        printf '%b%b' "${STYLE_RESET}" "${SEPARATOR_BRANCHES_REMOTE}"
        branching_status "${i}" "${STYLE_REMOTES_BRANCHES}"
    done

    # standard formating + chariage return at EOL ;)
    printf '%b\n' "${STYLE_RESET}"
}

# Give a short git status
git_status() {
    git status -s -unormal --column
}

# Give a quick overview of git stash
git_stash_status() {
    git stash list
}

git_branching_status
git_status
git_stash_status
printf '%b' "${STYLE_RESET}"
