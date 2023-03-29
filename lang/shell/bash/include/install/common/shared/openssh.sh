#!/usr/bin/env bash

main() {
    # """
    # Install OpenSSH.
    # @note Updated 2022-08-11.
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
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'make' 'pkg-config'
    koopa_activate_app \
        'zlib' \
        'libedit' \
        'openssl3'
    declare -A app=(
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['name']='openssh'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="${dict['name']}-${dict['version']}.tar.gz"
    dict['url']="https://cloudflare.cdn.openbsd.org/pub/OpenBSD/OpenSSH/\
portable/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    dict['ssl']="$(koopa_app_prefix 'openssl3')"
    conf_args=(
        # > '--with-security-key-builtin' # libfido2
        "--prefix=${dict['prefix']}"
        '--with-libedit'
        "--with-ssl-dir=${dict['ssl']}"
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
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
