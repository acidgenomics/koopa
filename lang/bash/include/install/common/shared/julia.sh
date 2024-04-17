#!/usr/bin/env bash

main() {
    # """
    # Install Julia.
    # @note Updated 2024-04-17.
    #
    # @seealso
    # - https://github.com/JuliaLang/julia/blob/master/doc/build/build.md
    # - https://github.com/JuliaLang/julia/blob/master/doc/build/linux.md
    # - https://docs.julialang.org/en/v1/devdocs/llvm/
    # - https://github.com/JuliaLang/julia/blob/master/doc/build/build.md#llvm
    # - https://github.com/JuliaLang/julia/blob/master/Make.inc
    # - https://github.com/conda-forge/julia-feedstock
    # - https://formulae.brew.sh/formula/julia
    # - https://ports.macports.org/port/julia/details/
    # """
    local -A app dict
    local -a build_deps
    build_deps+=('bzip2' 'cmake' 'make' 'tar' 'xz')
    koopa_activate_app --build-only "${build_deps[@]}"
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/JuliaLang/julia/releases/download/\
v${dict['version']}/julia-${dict['version']}-full.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    # Customize the 'Make.user' file. Refer to 'Make.inc' for supported values.
    read -r -d '' "dict[make_user_string]" << END || true
prefix=${dict['prefix']}
libexecdir=${dict['prefix']}/lib
sysconfdir=${dict['prefix']}/etc
USE_BINARYBUILDER=1
END
    koopa_write_string \
        --file='Make.user' \
        --string="${dict['make_user_string']}"
    koopa_add_to_path_end '/usr/sbin' '/sbin'
    koopa_print_env
    koopa_print "${dict['make_user_string']}"
    "${app['make']}" --jobs="${dict['jobs']}"
    "${app['make']}" install
    app['julia']="${dict['prefix']}/bin/julia"
    koopa_assert_is_executable "${app['julia']}"
    "${app['julia']}" --version
    return 0
}
