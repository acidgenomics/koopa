#!/usr/bin/env bash

install_from_conda() {
    _koopa_install_conda_package
    return 0
}

install_from_source() {
    # """
    # Install minimap2.
    # @note Updated 2023-05-04.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     minimap2.rb
    # - https://github.com/bioconda/bioconda-recipes/tree/master/recipes/
    #     minimap2
    # """
    #
    local -A app dict
    local -a includes libs
    _koopa_assert_is_not_arm64
    _koopa_activate_app 'zlib'
    app['make']="$(_koopa_locate_make)"
    _koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(_koopa_cpu_count)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['zlib']="$(_koopa_app_prefix 'zlib')"
    dict['url']="https://github.com/lh3/minimap2/archive/refs/tags/\
v${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_print_env
    includes=(
        "-I${dict['zlib']}/include"
    )
    libs=(
        '-lm' '-lz' '-lpthread'
        "-L${dict['zlib']}/lib"
        "-Wl,-rpath,${dict['zlib']}/lib"
    )
    "${app['make']}" \
        --jobs="${dict['jobs']}" \
        INCLUDES="${includes[*]}" \
        LIBS="${libs[*]}" \
        VERBOSE=1
    _koopa_cp --target-directory="${dict['prefix']}/bin" 'minimap2'
    return 0
}

main() {
    install_from_conda
    return 0
}
