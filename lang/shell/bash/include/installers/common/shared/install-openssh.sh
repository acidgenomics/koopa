#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install OpenSSH.
    # @note Updated 2022-04-20.
    #
    # @section Privilege separation:
    #
    # To support Privilege Separation (which is now required) you will need
    # to create the user, group and directory used by sshd for privilege
    # separation.  See README.privsep for details.
    #
    # @seealso
    # - https://www.linuxfromscratch.org/blfs/view/svn/postlfs/openssh.html
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     openssh.rb
    # - https://forums.gentoo.org/viewtopic-t-1085536-start-0.html
    # - https://stackoverflow.com/questions/11841919/
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='openssh'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="https://cloudflare.cdn.openbsd.org/pub/OpenBSD/OpenSSH/\
portable/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    conf_args=(
        "--prefix=${dict[prefix]}"
        '--with-kerberos5'
        '--with-pam'
        '--with-security-key-builtin'
        '--without-ldns'
        '--without-libedit'
    )
    if koopa_is_linux
    then
        conf_args+=(
            "--with-privsep-path=${dict[prefix]}/var/lib/sshd"
        )
    fi
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
