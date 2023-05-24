#!/usr/bin/env bash

main() {
    # """
    # Install Boost library.
    # @note Updated 2023-04-10.
    #
    # @seealso
    # - https://www.boost.org/users/download/
    # - https://github.com/conda-forge/boost-feedstock/blob/main/recipe/build.sh
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/boost.rb
    # """
    local -A dict
    local -a b2_args bootstrap_args deps
    deps=('bzip2' 'icu4c' 'xz' 'zlib' 'zstd')
    koopa_activate_app "${deps[@]}"
    dict['icu4c']="$(koopa_app_prefix 'icu4c')"
    dict['jobs']="$(koopa_cpu_count)"
    dict['name']='boost'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    if koopa_is_macos
    then
        dict['toolset']='clang'
    else
        dict['toolset']='gcc'
    fi
    dict['snake_version']="$(koopa_snake_case_simple "${dict['version']}")"
    dict['file']="${dict['name']}_${dict['snake_version']}.tar.bz2"
    dict['url']="https://boostorg.jfrog.io/artifactory/main/release/\
${dict['version']}/source/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}_${dict['snake_version']}"
    bootstrap_args=(
        "--libdir=${dict['prefix']}/lib"
        "--prefix=${dict['prefix']}"
        "--with-icu=${dict['icu4c']}"
        "--with-toolset=${dict['toolset']}"
        '--without-libraries=log,mpi,python'
    )
    b2_args=(
        # Stop on the first error.
        '-q'
        # Show commands as they are executed.
        '-d+2'
        "-j${dict['jobs']}"
        "--libdir=${dict['prefix']}/lib"
        "--prefix=${dict['prefix']}"
        "cxxflags=${CPPFLAGS:?}"
        'link=shared'
        "linkflags=${LDFLAGS:?}"
        'runtime-link=shared'
        "toolset=${dict['toolset']}"
        'threading=multi'
        'variant=release'
        'install'
    )
    koopa_print_env
    ./bootstrap.sh --help
    ./bootstrap.sh "${bootstrap_args[@]}"
    ./b2 --help
    ./b2 "${b2_args[@]}"
    return 0
}
