#!/usr/bin/env bash

# FIXME This make line is currently problematic on Linux:
# > /usr/bin/mkdir -p -m 0755 /var/empty

# FIXME Now seeing this:
# configure: WARNING: you should use --build, --host, --target

install_openssh() { # {{{1
    # """
    # Install OpenSSH.
    # @note Updated 2022-03-28.
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
        # > '--sysconfdir' '/etc/ssh'
        # > '--with-default-path' '/usr/bin'
        # > '--with-pid-dir' '/run'
        # > '--with-superuser-path' '/usr/sbin:/usr/bin'
        '--disable-etc-default-login'
        '--prefix' "${dict[prefix]}"
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
    "${app[make]}" test
    "${app[make]}" install
    return 0
}
