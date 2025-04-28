#!/usr/bin/env bash

install_from_juliaup() {
    # """
    # Install Julia using juliaup (recommended default).
    # @note Updatee 2025-04-28.
    #
    # @seealso
    # - https://github.com/JuliaLang/juliaup
    # - https://github.com/JuliaLang/julia
    # - https://discourse.julialang.org/t/
    #     custom-location-for-julia-using-juliaup/114724
    # - https://github.com/JuliaLang/juliaup/issues/705
    # """
    local -A app dict
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['libexec_prefix']="${dict['prefix']}/libexec"
    export JULIAUP_DEPOT_PATH="${dict['libexec_prefix']}"
    export JULIA_DEPOT_PATH="${dict['libexec_prefix']}"
    koopa_download \
        'https://install.julialang.org' \
        'juliaup.sh'
    koopa_chmod +x 'juliaup.sh'
    ./juliaup.sh \
        --add-to-path no \
        --background-selfupdate 0 \
        --default-channel "${dict['version']}" \
        --path "${dict['libexec_prefix']}" \
        --startup-selfupdate 0 \
        --yes
    app['julia']="${dict['prefix']}/bin/julia"
    app['julia_real']="${dict['libexec_prefix']}/bin/julia"
    app['juliaup']="${dict['libexec_prefix']}/bin/juliaup"
    koopa_assert_is_executable \
        "${app['julia_real']}" \
        "${app['juliaup']}"
    read -r -d '' "dict[julia_wrapper]" << END || true
#!/bin/sh
set -eu

${app['julia_real']} "\$@"
END
    koopa_write_string \
        --file="${app['julia']}" \
        --string="${dict['julia_wrapper']}"
    koopa_chmod +x "${app['julia']}"
    "${app['juliaup']}" add "${dict['version']}"
    "${app['juliaup']}" default "${dict['version']}"
    "${app['julia']}" --version
    return 0
}

install_from_source_with_binary_builder() {
    # """
    # Install Julia from source with binary builder.
    # @note Updated 2025-04-28.
    #
    # Currently buggy on Apple Silicon, so not using by default.
    #
    # @seealso
    # - https://github.com/JuliaLang/julia/blob/master/doc/build/build.md
    # - https://github.com/JuliaLang/julia/blob/master/doc/build/linux.md
    # - https://docs.julialang.org/en/v1/devdocs/llvm/
    # - https://github.com/JuliaLang/julia/blob/master/doc/build/build.md#llvm
    # - https://github.com/JuliaLang/julia/blob/master/Make.inc
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/julia.rb
    # - https://ports.macports.org/port/julia/details/
    # - https://git.alpinelinux.org/aports/tree/community/
    #     julia/APKBUILD?h=3.6-stable
    # """
    local -A app dict
    local -a build_deps
    build_deps=('bzip2' 'cmake' 'make' 'tar' 'xz')
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
VERBOSE=1
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

main() {
    install_from_juliaup "$@"
    return 0
}
