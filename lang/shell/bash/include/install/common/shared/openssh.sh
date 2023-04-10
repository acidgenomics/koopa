#!/usr/bin/env bash

main() {
    # """
    # Install OpenSSH.
    # @note Updated 2023-04-10.
    #
    # @section Privilege separation:
    #
    # To support Privilege Separation (which is now required) you will need
    # to create the user, group and directory used by sshd for privilege
    # separation.  See README.privsep for details.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     openssh.rb
    # - https://www.linuxfromscratch.org/blfs/view/svn/postlfs/openssh.html
    # - https://forums.gentoo.org/viewtopic-t-1085536-start-0.html
    # - https://stackoverflow.com/questions/11841919/
    # """
    local -A dict
    local -a conf_args
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app \
        'zlib' \
        'libedit' \
        'openssl3'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['openssl']="$(koopa_app_prefix 'openssl3')"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        # > '--with-security-key-builtin' # libfido2
        "--prefix=${dict['prefix']}"
        '--with-libedit'
        "--with-ssl-dir=${dict['openssl']}"
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
    koopa_make_build "${conf_args[@]}"
    return 0
}
