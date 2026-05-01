#!/usr/bin/env bash

_koopa_git_set_remote_url() {
    # """
    # Set (or change) the remote URL of a git repo.
    # @note Updated 2023-04-06.
    #
    # @examples
    # > repo='/opt/koopa'
    # > url='https://github.com/acidgenomics/koopa.git'
    # > _koopa_git_set_remote_url "$repo" "$url"
    # """
    local -A app dict
    _koopa_assert_has_args_eq "$#" 2
    app['git']="$(_koopa_locate_git --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['origin']='origin'
    dict['prefix']="${1:?}"
    dict['url']="${2:?}"
    _koopa_assert_is_git_repo "${dict['prefix']}"
    (
        _koopa_cd "${dict['prefix']}"
        "${app['git']}" remote set-url "${dict['origin']}" "${dict['url']}"
    )
    return 0
}
