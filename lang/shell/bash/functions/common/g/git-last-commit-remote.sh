#!/usr/bin/env bash

koopa_git_last_commit_remote() {
    # """
    # Last git commit of remote repository.
    # @note Updated 2021-11-23.
    #
    # @examples
    # > url='https://github.com/acidgenomics/koopa.git'
    # > koopa_git_last_commit_remote "$url"
    # # 73f50603e00c1c7c809a10b6187b40066b8a4e4d
    #
    # @seealso
    # > git ls-remote --help
    # """
    local app dict url
    koopa_assert_has_args "$#"
    declare -A app=(
        [awk]="$(koopa_locate_awk)"
        [git]="$(koopa_locate_git)"
        [head]="$(koopa_locate_head)"
    )
    declare -A dict=(
        [ref]='HEAD'
    )
    for url in "$@"
    do
        local x
        # shellcheck disable=SC2016
        x="$( \
            "${app[git]}" ls-remote --quiet "$url" "${dict[ref]}" \
            | "${app[head]}" -n 1 \
            | "${app[awk]}" '{ print $1 }' \
        )"
        [[ -n "$x" ]] || return 1
        koopa_print "$x"
    done
    return 0
}
