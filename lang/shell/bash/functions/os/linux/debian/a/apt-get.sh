#!/usr/bin/env bash

koopa_debian_apt_get() {
    # """
    # Non-interactive variant of apt-get, with saner defaults.
    # @note Updated 2023-05-10.
    #
    # Ubuntu 22 is annoying about needrestart triggers breaking
    # non-interactive scripts.
    #
    # Currently intended for:
    # - dist-upgrade
    # - install
    #
    # @seealso
    # - man apt-get
    # - https://manpages.ubuntu.com/manpages/jammy/en/man8/apt-get.8.html
    # - https://manpages.ubuntu.com/manpages/jammy/man7/debconf.7.html
    # - https://manpages.ubuntu.com/manpages/xenial/man1/dpkg.1.html
    # """
    local -A app
    local -a apt_args
    koopa_assert_has_args "$#"
    koopa_assert_is_admin
    app['apt_get']="$(koopa_debian_locate_apt_get)"
    koopa_assert_is_executable "${app[@]}"
    apt_args=(
        '--assume-yes'
        '--no-install-recommends'
        '--quiet'
        # > '-o' 'Dpkg::Options::=--force-confdef'
        # > '-o' 'Dpkg::Options::=--force-confold'
    )
    koopa_sudo \
        DEBCONF_NONINTERACTIVE_SEEN='true' \
        DEBIAN_FRONTEND='noninteractive' \
        "${app['apt_get']}" "${apt_args[@]}" \
        "$@"
    return 0
}
