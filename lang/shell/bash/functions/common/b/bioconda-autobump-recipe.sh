#!/usr/bin/env bash

koopa_bioconda_autobump_recipe() {
    # """
    # Edit a Bioconda autobump recipe.
    # @note Updated 2022-11-09.
    # """
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        ['git']="$(koopa_locate_git --allow-system)"
        ['vim']="$(koopa_locate_vim --allow-system)"
    )
    [[ -x "${app['git']}" ]] || return 1
    [[ -x "${app['vim']}" ]] || return 1
    declare -A dict=(
        ['recipe']="${1:?}"
        ['repo']="${HOME:?}/git/bioconda-recipes"
    )
    dict['branch']="${dict['recipe']/-/_}"
    koopa_assert_is_dir "${dict['repo']}"
    (
        koopa_cd "${dict['repo']}"
        "${app['git']}" checkout master
        "${app['git']}" fetch --all
        "${app['git']}" pull
        # Autobump branch:
        "${app['git']}" checkout \
            -B "${dict['branch']}" \
            "origin/bump/${dict['branch']}"
        # Or create a new branch:
        # > "${app['git']}" checkout -B "$branch"
        "${app['git']}" pull origin master
        koopa_mkdir "recipes/${dict['recipe']}"
        "${app['vim']}" "recipes/${dict['recipe']}/meta.yaml"
    )
    return 0
}
