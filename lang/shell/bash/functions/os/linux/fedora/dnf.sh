#!/usr/bin/env bash

koopa_fedora_dnf() {
    # """
    # Use 'dnf' to manage packages.
    # @note Updated 2022-05-19.
    #
    # Previously defined as 'yum' in versions prior to RHEL 8.
    # """
    local app
    declare -A app=(
        [dnf]="$(koopa_fedora_locate_dnf)"
        [sudo]="$(koopa_locate_sudo)"
    )
    [[ -x "${app[dnf]}" ]] || return 1
    [[ -x "${app[sudo]}" ]] || return 1
    "${app[sudo]}" "${app[dnf]}" -y "$@"
    return 0
}
