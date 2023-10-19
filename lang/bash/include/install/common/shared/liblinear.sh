#!/usr/bin/env bash

main() {
    # """
    # Install liblinear.
    # @note Updated 2023-10-19.
    #
    # @seealso
    # - https://www.csie.ntu.edu.tw/~cjlin/liblinear/
    # - https://formulae.brew.sh/formula/liblinear
    # """
    local -A app dict
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://www.csie.ntu.edu.tw/~cjlin/liblinear/oldfiles/\
liblinear-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    "${app['make']}" all lib
    # Alternatively, can extraction version from 'SHVER' in 'Makefile'.
    koopa_ln 'liblinear.so.'* 'liblinear.so'
    koopa_cp \
        --target-directory="${dict['prefix']}/bin" \
        'predict' 'train'
    koopa_cp \
        --target-directory="${dict['prefix']}/include" \
        './'*'.h'
    koopa_cp \
        --target-directory="${dict['prefix']}/lib" \
        './'*'.so' './'*'.so.'*
    return 0
}
