#!/usr/bin/env bash

koopa_git_set_remote_url() {
    # """
    # Set (or change) the remote URL of a git repo.
    # @note Updated 2023-04-06.
    #
    # @examples
    # > repo='/opt/koopa'
    # > url='https://github.com/acidgenomics/koopa.git'
    # > koopa_git_set_remote_url "$repo" "$url"
    # """
    local -A app dict
    koopa_assert_has_args_eq "$#" 2
    app['git']="$(koopa_locate_git --allow-system)"
    [[ -x "${app['git']}" ]] || exit 1
    dict['origin']='origin'
    dict['prefix']="${1:?}"
    dict['url']="${2:?}"
    koopa_assert_is_git_repo "${dict['prefix']}"
    (
        koopa_cd "${dict['prefix']}"
        "${app['git']}" remote set-url "${dict['origin']}" "${dict['url']}"
    )
    return 0
}
