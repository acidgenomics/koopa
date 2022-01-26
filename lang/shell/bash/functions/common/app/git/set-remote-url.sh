#!/usr/bin/env bash

koopa::git_set_remote_url() { # {{{1
    # """
    # Set (or change) the remote URL of a git repo.
    # @note Updated 2021-11-18.
    #
    # @examples
    # > repo='/opt/koopa'
    # > url='https://github.com/acidgenomics/koopa.git'
    # > cd "$repo"
    # > koopa::git_set_remote_url "$url"
    # """
    local app dict
    koopa::assert_has_args_eq "$#" 1
    koopa::assert_is_git_repo
    declare -A app=(
        [git]="$(koopa::locate_git)"
    )
    declare -A dict=(
        [url]="${1:?}"
        [origin]='origin'
    )
    "${app[git]}" remote set-url "${dict[origin]}" "${dict[url]}"
    return 0
}
