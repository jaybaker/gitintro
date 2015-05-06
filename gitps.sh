#!/bin/bash

# To use these routines:
#
#    1) Copy this file to somewhere (e.g. ~/.git-completion.sh).
#    2) Added the following line to your .bashrc:
#        source ~/.git-completion.sh
#
#    3) You may want to make sure the git executable is available
#       in your PATH before this script is sourced, as some caching
#       is performed while the script loads.  If git isn't found
#       at source time then all lookups will be done on demand,
#       which may be slightly slower.
#
#    4) Consider changing your PS1 to also show the current branch:
#        PS1='[\u@\h \W$(__git_ps1 " (%s)")]\$ '
#
#       The argument to __git_ps1 will be displayed only if you
#       are currently in a git repository.  The %s token will be
#       the name of the current branch.
#
#       In addition, if you set GIT_PS1_SHOWDIRTYSTATE to a nonempty
#       value, unstaged (*) and staged (+) changes will be shown next
#       to the branch name.  You can configure this per-repository
#       with the bash.showDirtyState variable, which defaults to true
#       once GIT_PS1_SHOWDIRTYSTATE is enabled.
#
#       You can also see if currently something is stashed, by setting
#       GIT_PS1_SHOWSTASHSTATE to a nonempty value. If something is stashed,
#       then a '$' will be shown next to the branch name.
#
#       If you would like to see if there're untracked files, then you can
#       set GIT_PS1_SHOWUNTRACKEDFILES to a nonempty value. If there're
#       untracked files, then a '%' will be shown next to the branch name.

# __gitdir accepts 0 or 1 arguments (i.e., location)
# returns location of .git repo
__gitdir ()
{
        if [ -z "${1-}" ]; then
                if [ -n "${__git_dir-}" ]; then
                        echo "$__git_dir"
                elif [ -d .git ]; then
                        echo .git
                else
                        git rev-parse --git-dir 2>/dev/null
                fi
        elif [ -d "$1/.git" ]; then
                echo "$1/.git"
        else
                echo "$1"
        fi
}


# __git_ps1 accepts 0 or 1 arguments (i.e., format string)
# returns text to add to bash PS1 prompt (includes branch name)
__git_ps1 ()
{
        local g="$(__gitdir)"
        if [ -n "$g" ]; then
                local r
                local b
                if [ -f "$g/rebase-merge/interactive" ]; then
                        r="|REBASE-i"
                        b="$(cat "$g/rebase-merge/head-name")"
                elif [ -d "$g/rebase-merge" ]; then
                        r="|REBASE-m"
                        b="$(cat "$g/rebase-merge/head-name")"
                else
                        if [ -d "$g/rebase-apply" ]; then
                                if [ -f "$g/rebase-apply/rebasing" ]; then
                                        r="|REBASE"
                                elif [ -f "$g/rebase-apply/applying" ]; then
                                        r="|AM"
                                else
                                        r="|AM/REBASE"
                                fi
                        elif [ -f "$g/MERGE_HEAD" ]; then
                                r="|MERGING"
                        elif [ -f "$g/BISECT_LOG" ]; then
                                r="|BISECTING"
                        fi

                        b="$(git symbolic-ref HEAD 2>/dev/null)" || {

                                b="$(
                                case "${GIT_PS1_DESCRIBE_STYLE-}" in
                                (contains)
                                        git describe --contains HEAD ;;
                                (branch)
                                        git describe --contains --all HEAD ;;
                                (describe)
                                        git describe HEAD ;;
                                (* | default)
                                        git describe --exact-match HEAD ;;
                                esac 2>/dev/null)" ||

                                b="$(cut -c1-7 "$g/HEAD" 2>/dev/null)..." ||
                                b="unknown"
                                b="($b)"
                        }
                fi

                local w
                local i
                local s
                local u
                local c

                if [ "true" = "$(git rev-parse --is-inside-git-dir 2>/dev/null)" ]; then
                        if [ "true" = "$(git rev-parse --is-bare-repository 2>/dev/null)" ]; then
                                c="BARE:"
                        else
                                b="GIT_DIR!"
                        fi
                elif [ "true" = "$(git rev-parse --is-inside-work-tree 2>/dev/null)" ]; then
                        if [ -n "${GIT_PS1_SHOWDIRTYSTATE-}" ]; then
                                if [ "$(git config --bool bash.showDirtyState)" != "false" ]; then
                                        git diff --no-ext-diff --ignore-submodules \
                                                --quiet --exit-code || w="*"
                                        if git rev-parse --quiet --verify HEAD >/dev/null; then
                                                git diff-index --cached --quiet \
                                                        --ignore-submodules HEAD -- || i="+"
                                        else
                                                i="#"
                                        fi
                                fi
                        fi
                        if [ -n "${GIT_PS1_SHOWSTASHSTATE-}" ]; then
                                git rev-parse --verify refs/stash >/dev/null 2>&1 && s="$"
                        fi

                        if [ -n "${GIT_PS1_SHOWUNTRACKEDFILES-}" ]; then
                           if [ -n "$(git ls-files --others --exclude-standard)" ]; then
                              u="%"
                           fi
                        fi
                fi

                if [ -n "${1-}" ]; then
                        printf "$1" "$c${b##refs/heads/}$w$i$s$u$r"
                else
                        printf " (%s)" "$c${b##refs/heads/}$w$i$s$u$r"
                fi
        fi
}
