#!/usr/bin/env bash

_koopa_fedora_dnf() {
    # """
    # Use 'dnf' to manage packages.
    # @note Updated 2023-05-01.
    #
    # Previously defined as 'yum' in versions prior to RHEL 8.
    # """
    local -A app
    _koopa_assert_has_args "$#"
    _koopa_assert_is_admin
    app['dnf']="$(_koopa_fedora_locate_dnf)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_sudo "${app['dnf']}" -y "$@"
    return 0
}
