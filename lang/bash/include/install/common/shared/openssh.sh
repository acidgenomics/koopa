#!/usr/bin/env bash

# FIXME Now hitting a segmentation fault:
# /bin/bash: line 2: 89117 Segmentation fault: 11  ./ssh-keygen -A
# gmake: *** [Makefile:447: host-key] Error 139

main() {
    # """
    # Install OpenSSH.
    # @note Updated 2023-05-26.
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
    build_deps=('pkg-config')
    deps=(
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
        "--prefix=${dict['prefix']}"
        "--sbindir=${dict['prefix']}/bin"
        "--with-kerberos5=${dict['krb5']}"
        "--with-ldns=${dict['ldns']}"
        "--with-libedit=${dict['libedit']}"
        '--with-pam'
        '--with-security-key-builtin'
        "--with-ssl-dir=${dict['openssl']}"
        "--with-zlib=${dict['zlib']}"
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
    # > CFLAGS="${CFLAGS:-}"
    # > if koopa_is_macos
    # > then
    # >     koopa_stop 'FIXME'
        # https://github.com/apple-oss-distributions/OpenSSH/blob/main/openssh/sandbox-darwin.c#L66
        # url "https://raw.githubusercontent.com/Homebrew/patches/1860b0a745f1fe726900974845d1b0dd3c3398d6/openssh/patch-sandbox-darwin.c-apple-sandbox-named-external.diff"
        # https://github.com/apple-oss-distributions/OpenSSH/blob/main/openssh/sshd.c#L532
        # url "https://raw.githubusercontent.com/Homebrew/patches/d8b2d8c2612fd251ac6de17bf0cc5174c3aab94c/openssh/patch-sshd.c-apple-sandbox-named-external.diff"
        # FIXME Need to update the sandbox prefix.
        # Use our dict prefix here for 'etc/ssh'...check this.
        # inreplace "sandbox-darwin.c", "@PREFIX@/share/openssh", etc/"ssh"
        # > CFLAGS="${CFLAGS:-} -D__APPLE_SANDBOX_NAMED_EXTERNAL__"
    # > fi
    # > export CFLAGS
    # FIXME May need to deparallelize the build here.
    koopa_make_build "${conf_args[@]}"
    (
        koopa_cd "${dict['prefix']}/bin"
        koopa_ln 'ssh' 'slogin'
    )
    #if koopa_is_macos
    #then
    #    koopa_stop "Need to copy sb file into 'etc/ssh'."
    #    # "https://raw.githubusercontent.com/apple-oss-distributions/OpenSSH/OpenSSH-268.100.4/com.openssh.sshd.sb"
    #fi
    return 0
}
