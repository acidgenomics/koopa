#!/usr/bin/env bash

koopa::install_julia_packages() { # {{{1
    # """
    # Install Julia packages.
    # @note Updated 2021-06-14.
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
    local eval_string
    koopa::configure_julia
    read -r -d '' eval_string << END || true
using Pkg
Pkg.add("DataFrames")
Pkg.add("BioCore")
Pkg.add("BioSymbols")
Pkg.add("GenomeGraphs")
Pkg.add("BioGenerics")
Pkg.add("BigBed")
Pkg.add("BioSequences")
Pkg.add("XAM")
END
    julia --eval="$eval_string"
    return 0
}

koopa::uninstall_julia_packages() { # {{{1
    # """
    # Uninstall Julia packages.
    # @note Updated 2021-06-14.
    # """
    koopa::stop 'FIXME add this'
    return 0
}

koopa::update_julia_packages() { # {{{1
    # """
    # Update Julia packages.
    # @note Updated 2021-06-14.
    # """
    koopa::stop 'FIXME add this'
    return 0
}
