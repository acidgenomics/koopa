#!/usr/bin/env bash

koopa_fedora_dnf() {
    # """
    # Use 'dnf' to manage packages.
    # @note Updated 2023-05-01.
    #
    # Previously defined as 'yum' in versions prior to RHEL 8.
    # """
    local -A app
    koopa_assert_has_args "$#"
    koopa_assert_is_admin
    app['dnf']="$(koopa_fedora_locate_dnf)"
    koopa_assert_is_executable "${app[@]}"
    koopa_sudo "${app['dnf']}" -y "$@"
    return 0
}
