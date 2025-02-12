#!/usr/bin/env bash

main() {
    # """
    # Install libxslt.
    # @note Updated 2023-05-24.
    #
    # @seealso
    # - http://xmlsoft.org/XSLT/
    # - https://formulae.brew.sh/formula/libxslt/
    # """
    local -A dict
    local -a build_deps conf_args deps
    build_deps=('pkg-config')
    deps=(
        'icu4c75' # libxml2
        'libxml2'
        'libgpg-error' # libgcrypt
        'libgcrypt'
    )
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    dict['libxml']="$(koopa_app_prefix 'libxml2')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['maj_min_ver']="$(koopa_major_minor_version "${dict['version']}")"
    conf_args=(
        '--disable-dependency-tracking'
        '--disable-silent-rules'
        "--prefix=${dict['prefix']}"
        '--with-crypto'
        "--with-libxml-prefix=${dict['libxml']}"
        '--without-python'
    )
    dict['url']="https://download.gnome.org/sources/libxslt/\
${dict['maj_min_ver']}/libxslt-${dict['version']}.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
