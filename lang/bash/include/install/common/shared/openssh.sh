#!/usr/bin/env bash

main() {
    # """
    # Install OpenSSH.
    # @note Updated 2023-05-25.
    #
    # @section Privilege separation:
    #
    # To support Privilege Separation (which is now required) you will need
    # to create the user, group and directory used by sshd for privilege
    # separation.  See README.privsep for details.
    #
    # @seealso
    # - https://github.com/conda-forge/openssh-feedstock
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     openssh.rb
    # - https://www.linuxfromscratch.org/blfs/view/svn/postlfs/openssh.html
    # - https://forums.gentoo.org/viewtopic-t-1085536-start-0.html
    # - https://stackoverflow.com/questions/11841919/
    # """
    local -A app dict
    local -a conf_args
    koopa_activate_app --build-only 'make' 'pkg-config'
    koopa_activate_app \
        'zlib' \
        'libedit' \
        'openssl3'
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_installed "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
    dict['openssl']="$(koopa_app_prefix 'openssl3')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['zlib']="$(koopa_app_prefix 'zlib')"
    conf_args=(
        # > '--with-security-key-builtin' # libfido2
        "--prefix=${dict['prefix']}"
        "--sbindir=${dict['prefix']}/bin"
        '--with-libedit'
        "--with-ssl-dir=${dict['openssl']}"
        "--with-zlib=${dict['zlib']}"
        '--without-kerberos5'
        '--without-ldns'
        '--without-pam'
    )
    if koopa_is_linux
    then
        conf_args+=(
            "--with-privsep-path=${dict['prefix']}/var/lib/sshd"
        )
    fi
    dict['url']="https://cloudflare.cdn.openbsd.org/pub/OpenBSD/OpenSSH/\
portable/openssh-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    ./configure --help || true
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install-nokeys
    return 0
}
