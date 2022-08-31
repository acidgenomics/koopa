#!/usr/bin/env bash

koopa_git_set_remote_url() {
    # """
    # Set (or change) the remote URL of a git repo.
    # @note Updated 2022-08-30.
    #
    # @examples
    # > repo='/opt/koopa'
    # > url='https://github.com/acidgenomics/koopa.git'
    # > cd "$repo"
    # > koopa_git_set_remote_url "$url"
    # """
    local app dict
    koopa_assert_has_args_eq "$#" 1
    koopa_assert_is_git_repo
    declare -A app
    app['git']="$(koopa_locate_git --allow-system)"
    [[ -x "${app['git']}" ]] || return 1
    declare -A dict=(
        ['url']="${1:?}"
        ['origin']='origin'
    )
    "${app['git']}" remote set-url "${dict['origin']}" "${dict['url']}"
    return 0
}
