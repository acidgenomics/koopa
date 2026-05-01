#!/usr/bin/env bash

# FIXME This isn't building correctly on Apple Silicon.

main() {
    # """
    # Install HISAT2.
    # @note Updated 2023-10-10.
    #
    # @seealso
    # - https://github.com/bioconda/bioconda-recipes/tree/master/recipes/hisat2
    # """
    local -A app dict
    app['make']="$(_koopa_locate_make)"
    app['patch']="$(_koopa_locate_patch)"
    app['cc']="$(_koopa_locate_cc --only-system)"
    app['cxx']="$(_koopa_locate_cxx --only-system)"
    _koopa_assert_is_installed "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/DaehwanKimLab/hisat2/archive/\
v${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    dict['patch_prefix']="$(_koopa_patch_prefix)/common/hisat2"
    _koopa_assert_is_dir "${dict['patch_prefix']}"
    dict['patch_file']="${dict['patch_prefix']}/version.patch"
    _koopa_assert_is_file "${dict['patch_file']}"
    "${app['patch']}" \
        --input="${dict['patch_file']}" \
        --strip=1 \
        --verbose
    _koopa_print_env
    "${app['make']}" \
        CC="${app['cc']}} ${CFLAGS:-} ${CPPFLAGS:-} ${LDFLAGS:-}" \
        CPP="${app['cxx']} ${CXXFLAGS:-} ${CPPFLAGS:-} ${LDFLAGS:-}"
    # Copy binaries and Python scripts.
    _koopa_mkdir "${dict['prefix']}/bin"
    _koopa_cp \
        --target-directory="${dict['prefix']}/bin" \
        'hisat2' \
        'hisat2-align-l' \
        'hisat2-align-s' \
        'hisat2-build' \
        'hisat2-build-l' \
        'hisat2-build-s' \
        'hisat2-inspect' \
        'hisat2-inspect-l' \
        'hisat2-inspect-s' \
        *'.py'
    _koopa_chmod +x "${dict['prefix']}/bin/"*
    return 0
}
