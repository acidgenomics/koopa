#!/usr/bin/env bash

main() {
    # """
    # Install Julia (from source).
    # @note Updated 2023-04-06.
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
    koopa_assert_has_no_args "$#"
    build_deps=('bzip2' 'cmake' 'make' 'tar' 'xz')
    koopa_activate_app --build-only "${build_deps[@]}"
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
    dict['name']='julia'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['file']="${dict['name']}-${dict['version']}-full.tar.gz"
    dict['url']="https://github.com/JuliaLang/julia/releases/download/\
v${dict['version']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
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
    koopa_add_to_path_end '/usr/sbin'
    koopa_print_env
    koopa_print "${dict['make_user_string']}"
    "${app['make']}" --jobs="${dict['jobs']}"
    # > "${app['make']}" test
    "${app['make']}" install
    return 0
}
