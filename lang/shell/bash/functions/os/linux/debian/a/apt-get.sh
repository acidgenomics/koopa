#!/usr/bin/env bash

# FIXME R system install is erroring out here:
# Processing triggers for install-info (6.8-4build1) ...
# NEEDRESTART-VER: 3.5
# NEEDRESTART-KCUR: 5.19.0-1024-aws
# NEEDRESTART-KEXP: 5.19.0-1024-aws
# NEEDRESTART-KSTA: 1

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
    # - https://bugs.launchpad.net/ubuntu/+source/ubuntu-advantage-tools/
    #     +bug/2004203
    # """
    local -A app
    local -a apt_args
    koopa_assert_has_args "$#"
    app['apt_get']="$(koopa_debian_locate_apt_get)"
    koopa_assert_is_executable "${app[@]}"
    apt_args=(
        # > '--allow-unauthenticated'
        # > '--yes'
        '--assume-yes'
        '--no-install-recommends'
        '--quiet'
        '-o' 'Dpkg::Options::=--force-confdef'
        '-o' 'Dpkg::Options::=--force-confold'
    )
    koopa_sudo \
        DEBIAN_FRONTEND='noninteractive' \
        "${app['apt_get']}" \
        update
    koopa_sudo \
        DEBIAN_FRONTEND='noninteractive' \
        "${app['apt_get']}" "${apt_args[@]}" \
        "$@"
    return 0
}
