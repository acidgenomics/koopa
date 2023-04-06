#!/usr/bin/env bash

koopa_fedora_dnf() {
    # """
    # Use 'dnf' to manage packages.
    # @note Updated 2023-04-05.
    #
    # Previously defined as 'yum' in versions prior to RHEL 8.
    # """
    local -A app
    app['dnf']="$(koopa_fedora_locate_dnf)"
    app['sudo']="$(koopa_locate_sudo)"
    koopa_assert_is_executable "${app[@]}"
    "${app['sudo']}" "${app['dnf']}" -y "$@"
    return 0
}
