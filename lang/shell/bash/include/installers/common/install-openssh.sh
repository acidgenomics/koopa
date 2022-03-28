#!/usr/bin/env bash

# FIXME This make line is currently problematic on Linux:
# > /usr/bin/mkdir -p -m 0755 /var/empty

install_openssh() { # {{{1
    # """
    # Install OpenSSH.
    # @note Updated 2022-03-28.
    #
    # @seealso
    # - https://www.linuxfromscratch.org/blfs/view/svn/postlfs/openssh.html
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     openssh.rb
    # - https://forums.gentoo.org/viewtopic-t-1085536-start-0.html
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
        # > '--with-default-path' '/usr/bin'
        # > '--with-pid-dir' '/run'
        # > '--with-superuser-path' '/usr/sbin:/usr/bin'
        '--prefix' "${dict[prefix]}"
        '--sysconfdir' '/etc/ssh'
        '--with-kerberos5'
        '--with-ldns'
        '--with-libedit'
        '--with-pam'
        '--with-security-key-builtin'
    )
    if koopa_is_linux
    then
        conf_args+=(
            '--with-privsep-path' '/var/lib/sshd'
        )
    fi
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
