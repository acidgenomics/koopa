#!/usr/bin/env bash

# FIXME Hitting this build error on Ubuntu 22:
# checking for el_init in -ledit... no
# configure: error: libedit not found

main() {
    # """
    # Install OpenSSH.
    # @note Updated 2023-10-19.
    #
    # @section Privilege separation:
    #
    # To support Privilege Separation (which is now required) you will need
    # to create the user, group and directory used by sshd for privilege
    # separation.  See README.privsep for details.
    #
    # @seealso
    # - https://github.com/conda-forge/openssh-feedstock
    # - https://formulae.brew.sh/formula/openssh
    # - https://www.linuxfromscratch.org/blfs/view/svn/postlfs/openssh.html
    # - https://forums.gentoo.org/viewtopic-t-1085536-start-0.html
    # - https://stackoverflow.com/questions/11841919/
    # """
    local -A dict
    local -a build_deps conf_args deps
    build_deps+=('pkg-config')
    deps+=(
        'zlib'
        'openssl3'
        'ldns'
        'libedit'
        'libfido2'
        'libxcrypt'
        'krb5'
    )
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    dict['jobs']="$(koopa_cpu_count)"
    dict['krb5']="$(koopa_app_prefix 'krb5')"
    dict['ldns']="$(koopa_app_prefix 'ldns')"
    dict['libedit']="$(koopa_app_prefix 'libedit')"
    dict['openssl']="$(koopa_app_prefix 'openssl3')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['zlib']="$(koopa_app_prefix 'zlib')"
    conf_args=(
        "--mandir=${dict['prefix']}/share/man"
        "--prefix=${dict['prefix']}"
        "--sbindir=${dict['prefix']}/bin"
        "--sysconfdir=${dict['prefix']}/etc/ssh"
        '--with-audit=bsm'
        "--with-kerberos5=${dict['krb5']}"
        "--with-ldns=${dict['ldns']}"
        '--with-md5-passwords'
        '--with-pam'
        "--with-pid-dir=${dict['prefix']}/var/run"
        '--with-security-key-builtin'
        "--with-ssl-dir=${dict['openssl']}"
        "--with-zlib=${dict['zlib']}"
        '--without-xauth'
        '--without-zlib-version-check'
    )
    if koopa_is_macos
    then
        conf_args+=(
            "--with-libedit=${dict['libedit']}"
            '--with-keychain=apple'
            '--with-privsep-path=/var/empty'
        )
    fi
    if koopa_is_linux
    then
        conf_args+=(
            '--with-libedit'
            "--with-privsep-path=${dict['prefix']}/var/lib/sshd"
        )
    fi
    dict['url']="https://cloudflare.cdn.openbsd.org/pub/OpenBSD/OpenSSH/\
portable/openssh-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build \
        --target='install-nokeys' \
        "${conf_args[@]}"
    (
        koopa_cd "${dict['prefix']}/bin"
        koopa_ln 'ssh' 'slogin'
    )
    return 0
}
