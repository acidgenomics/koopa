#!/usr/bin/env bash

# FIXME This step is erroring out for 'r-base' and 'r-base-dev'.

# FIXME Fix needrestart automatically if necessary.
# /etc/needrestart/needrestart.conf
# > #$nrconf{restart} = 'i';
# > $nrconf{restart} = 'l';

koopa_debian_apt_get() {
    # """
    # Non-interactive variant of apt-get, with saner defaults.
    # @note Updated 2023-05-10.
    #
    # Ubuntu 22 is annoying about 'NEEDRESTART' triggers breaking
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
    #
    # - Issues with needrestart not working non-interactively with 22:
    #   - https://bugs.launchpad.net/ubuntu/+source/ubuntu-advantage-tools/
    #       +bug/2004203
    #   - https://bugs.launchpad.net/ubuntu/+source/needrestart/+bug/1941716
    #   - https://stackoverflow.com/questions/73397110/
    #   - https://github.com/liske/needrestart/issues/129
    #   - https://askubuntu.com/questions/1367139/
    #   - /etc/needrestart/needrestart.conf
    # """
    local -A app
    local -a apt_args
    koopa_assert_has_args "$#"
    koopa_assert_is_admin
    app['apt_get']="$(koopa_debian_locate_apt_get)"
    koopa_assert_is_executable "${app[@]}"
    apt_args=(
        # > '--allow-unauthenticated'
        '--assume-yes'
        '--no-install-recommends'
        '--quiet'
        '--verbose-versions'
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
