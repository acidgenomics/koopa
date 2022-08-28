#!/usr/bin/env bash

koopa_install_julia_packages() {
    # """
    # Install Julia packages.
    # @note Updated 2022-07-28.
    #
    # @seealso
    # - 'JULIA_DEPOT_PATH' in shell.
    # - 'DEPOT_PATH' in Julia. Can check with 'Base.DEPOT_PATH'.
    #   Currently defaults to '~/.julia' unless set otherwise.
    # - https://docs.julialang.org/en/v1/manual/environment-variables/
    # - https://pkgdocs.julialang.org/v1/managing-packages/
    # - https://pkgdocs.julialang.org/v1/api/
    # - https://biojulia.net
    # - https://github.com/BioJulia
    # - https://stackoverflow.com/questions/36398629/
    # - https://towardsdatascience.com/
    #     getting-familiar-with-biojulia-bioinformatics-for-julia-796438aa059
    # - https://juliaobserver.com/packages
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['julia']="$(koopa_locate_julia)"
    )
    [[ -x "${app['julia']}" ]] || return 1
    declare -A dict=(
        ['script_prefix']="$(koopa_julia_script_prefix)"
    )
    dict['script']="${dict['script_prefix']}/install-packages.jl"
    koopa_assert_is_file "${dict['script']}"
    koopa_activate_julia
    "${app['julia']}" "${dict['script']}"
    return 0
}
