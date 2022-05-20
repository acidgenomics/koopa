#!/usr/bin/env bash

koopa_brew_reset_core_repo() {
    # """
    # Ensure internal 'homebrew-core' repo is clean.
    # @note Updated 2021-10-27.
    # """
    local app branch origin prefix repo
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [brew]="$(koopa_locate_brew)"
        [git]="$(koopa_locate_git)"
    )
    repo='homebrew/core'
    origin='origin'
    (
        prefix="$("${app[brew]}" --repo "$repo")"
        koopa_assert_is_dir "$prefix"
        koopa_cd "$prefix"
        branch="$(koopa_git_default_branch)"
        "${app[git]}" checkout -q "$branch"
        "${app[git]}" branch -q "$branch" -u "${origin}/${branch}"
        "${app[git]}" reset -q --hard "${origin}/${branch}"
        "${app[git]}" branch -vv
    )
    return 0
}
