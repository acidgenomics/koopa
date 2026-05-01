#!/usr/bin/env bash

_koopa_bioconda_autobump_recipe() {
    # """
    # Edit a Bioconda autobump recipe.
    # @note Updated 2023-08-26.
    # """
    local -A app dict
    _koopa_assert_has_args_eq "$#" 1
    app['git']="$(_koopa_locate_git --allow-system)"
    app['vim']="$(_koopa_locate_vim --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['recipe']="${1:?}"
    dict['repo']="${HOME:?}/git/github/bioconda/bioconda-recipes"
    dict['branch']="${dict['recipe']/-/_}"
    _koopa_assert_is_dir "${dict['repo']}"
    (
        _koopa_cd "${dict['repo']}"
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
        _koopa_mkdir "recipes/${dict['recipe']}"
        "${app['vim']}" "recipes/${dict['recipe']}/meta.yaml"
    )
    return 0
}
