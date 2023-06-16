#!/usr/bin/env bash

main() {
    # """
    # Install STAR.
    # @note Updated 2023-06-16.
    # @seealso
    # - https://github.com/alexdobin/STAR/
    # - https://github.com/bioconda/bioconda-recipes/tree/master/recipes/star
    # """
    local -A app
    local -a make_args
    koopa_activate_app --build-only 'gcc' 'make'
    app['gcc']="$(koopa_locate_gcc --realpath)"
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/alexdobin/STAR/archive/\
${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src/source'
    make_args+=(
        "--jobs=${dict['jobs']}"
        "CXX=${app['gcc']}"
        'VERBOSE=1'
    )
    if koopa_is_macos
    then
        make_args+=('STARforMacStatic' 'STARlongForMacStatic')
    else
        make_args+=('STAR' 'STARlong')
    fi
    koopa_chmod +x 'STAR' 'STARlong'
    koopa_cp 'STAR' "${dict['prefix']}/bin/STAR"
    koopa_cp 'STARlong' "${dict['prefix']}/bin/STARlong"
    return 0
}
