#!/usr/bin/env bash

main() {
    # """
    # Install Ruby.
    # @note Updated 2023-04-10.
    #
    # @seealso
    # - https://www.ruby-lang.org/en/downloads/
    # - https://github.com/conda-forge/ruby-feedstock
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/ruby.rb
    # """
    local -A dict
    local -a conf_args deps
    deps=(
        'zlib'
        'openssl'
        'readline'
        'libyaml'
        'libffi'
    )
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app "${deps[@]}"
    dict['libffi']="$(koopa_app_prefix 'libffi')"
    dict['libyaml']="$(koopa_app_prefix 'libyaml')"
    dict['openssl']="$(koopa_app_prefix 'openssl')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['readline']="$(koopa_app_prefix 'readline')"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['zlib']="$(koopa_app_prefix 'zlib')"
    dict['maj_min_ver']="$(koopa_major_minor_version "${dict['version']}")"
    conf_args=(
        '--disable-install-doc'
        '--disable-silent-rules'
        '--enable-load-relative'
        '--enable-shared'
        "--prefix=${dict['prefix']}"
        "--with-libffi-dir=${dict['libffi']}"
        "--with-libyaml-dir=${dict['libyaml']}"
        "--with-openssl-dir=${dict['openssl']}"
        "--with-readline-dir=${dict['readline']}"
        "--with-zlib-dir=${dict['zlib']}"
        '--without-gmp'
    )
    koopa_is_macos && conf_args+=('--enable-dtrace')
    dict['url']="https://cache.ruby-lang.org/pub/ruby/${dict['maj_min_ver']}/\
ruby-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
