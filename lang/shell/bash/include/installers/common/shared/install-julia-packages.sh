#!/usr/bin/env bash

install_julia_packages() { # {{{1
    # """
    # Install Julia packages.
    # @note Updated 2022-03-01.
    #
    # @seealso
    # - 'JULIA_DEPOT_PATH' in shell.
    # - 'DEPOT_PATH' in Julia.
    # - https://docs.julialang.org/en/v1/
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
    koopa_activate_julia
    declare -A app=(
        [julia]="$(koopa_locate_julia)"
    )
    declare -A dict=(
        [script_prefix]="$(koopa_julia_script_prefix)"
    )
    dict[script]="${dict[script_prefix]}/install-packages.jl"
    koopa_assert_is_file "${dict[script]}"
    "${app[julia]}" "${dict[script]}"
    return 0
}
