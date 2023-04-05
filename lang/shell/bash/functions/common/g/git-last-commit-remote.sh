#!/usr/bin/env bash

koopa_git_last_commit_remote() {
    # """
    # Last git commit of remote repository.
    # @note Updated 2023-03-12.
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
    local -A app=(
        ['awk']="$(koopa_locate_awk --allow-system)"
        ['git']="$(koopa_locate_git --allow-system)"
        ['head']="$(koopa_locate_head --allow-system)"
    )
    [[ -x "${app['awk']}" ]] || exit 1
    [[ -x "${app['git']}" ]] || exit 1
    [[ -x "${app['head']}" ]] || exit 1
    local -A dict
    dict['ref']='HEAD'
    for url in "$@"
    do
        local string
        # shellcheck disable=SC2016
        string="$( \
            "${app['git']}" ls-remote --quiet "$url" "${dict['ref']}" \
            | "${app['head']}" -n 1 \
            | "${app['awk']}" '{ print $1 }' \
        )"
        [[ -n "$string" ]] || return 1
        koopa_print "$string"
    done
    return 0
}
