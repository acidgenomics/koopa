#!/usr/bin/env bash

koopa::git_default_branch() { # {{{1
    # """
    # Default branch of Git repository.
    # @note Updated 2021-11-23.
    #
    # Alternate approach:
    # > x="$( \
    # >     git symbolic-ref "refs/remotes/${remote}/HEAD" \
    # >         | sed "s@^refs/remotes/${remote}/@@" \
    # > )"
    #
    # @seealso
    # - https://stackoverflow.com/questions/28666357
    #
    # @examples
    # > koopa::git_default_branch "${HOME}/git/monorepo"
    # # main
    # """
    local app dict repos
    declare -A app=(
        [git]="$(koopa::locate_git)"
        [sed]="$(koopa::locate_sed)"
    )
    declare -A dict=(
        [remote]='origin'
    )
    repos=("$@")
    koopa::is_array_empty "${repos[@]}" && repos[0]="${PWD:?}"
    koopa::assert_is_dir "${repos[@]}"
    # Using a single subshell here to avoid performance hit during looping.
    # This single subshell is necessary so we don't change working directory.
    (
        local repo
        for repo in "${repos[@]}"
        do
            local x
            koopa::cd "$repo"
            koopa::is_git_repo || return 1
            x="$( \
                "${app[git]}" remote show "${dict[remote]}" \
                    | koopa::grep 'HEAD branch' \
                    | "${app[sed]}" 's/.*: //' \
            )"
            [[ -n "$x" ]] || return 1
            koopa::print "$x"
        done
    )
    return 0
}
