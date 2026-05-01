#!/usr/bin/env bash

_koopa_git_last_commit_remote() {
    # """
    # Last git commit of remote repository.
    # @note Updated 2023-04-05.
    #
    # @examples
    # > url='https://github.com/acidgenomics/koopa.git'
    # > _koopa_git_last_commit_remote "$url"
    # # 73f50603e00c1c7c809a10b6187b40066b8a4e4d
    #
    # @seealso
    # > git ls-remote --help
    # """
    local -A app dict
    local url
    _koopa_assert_has_args "$#"
    app['awk']="$(_koopa_locate_awk --allow-system)"
    app['git']="$(_koopa_locate_git --allow-system)"
    app['head']="$(_koopa_locate_head --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
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
        _koopa_print "$string"
    done
    return 0
}
