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
    app['make']="$(_koopa_locate_make)"
    app['patch']="$(_koopa_locate_patch)"
    _koopa_assert_is_executable "${app[@]}"
    dict['patch_prefix']="$(_koopa_patch_prefix)/common/liblinear"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['shared_ext']="$(_koopa_shared_ext)"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    _koopa_assert_is_dir "${dict['patch_prefix']}"
    dict['url']="https://www.csie.ntu.edu.tw/~cjlin/liblinear/oldfiles/\
liblinear-${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    # Fix shared extension handling.
    dict['patch_file']="${dict['patch_prefix']}/shared-ext.patch"
    _koopa_assert_is_file "${dict['patch_file']}"
    "${app['patch']}" \
        --strip=0 \
        --verbose \
        'Makefile' \
        "${dict['patch_file']}"
    _koopa_print_env
    "${app['make']}" all lib
    # Alternatively, can extraction version from 'SHVER' in 'Makefile'.
    if _koopa_is_macos
    then
        _koopa_ln \
            'liblinear.'*".${dict['shared_ext']}" \
            "liblinear.${dict['shared_ext']}"
    else
        _koopa_ln \
            "liblinear.${dict['shared_ext']}."* \
            "liblinear.${dict['shared_ext']}"
    fi
    _koopa_cp \
        --target-directory="${dict['prefix']}/bin" \
        'predict' 'train'
    _koopa_cp \
        --target-directory="${dict['prefix']}/include" \
        './'*'.h'
    _koopa_cp \
        --target-directory="${dict['prefix']}/lib" \
        './'*".${dict['shared_ext']}"
    if ! _koopa_is_macos
    then
        _koopa_cp \
            --target-directory="${dict['prefix']}/lib" \
            './'*".${dict['shared_ext']}."*
    fi
    return 0
}
