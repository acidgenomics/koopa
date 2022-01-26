#!/usr/bin/env bash

koopa::macos_clean_launch_services() { # {{{1
    # """
    # Clean launch services.
    # @note Updated 2021-11-16.
    # """
    local app
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    declare -A app=(
        [kill_all]="$(koopa::macos_locate_kill_all)"
        [lsregister]="$(koopa::macos_locate_lsregister)"
        [sudo]="$(koopa::locate_sudo)"
    )
    koopa::alert "Cleaning LaunchServices 'Open With' menu."
    "${app[lsregister]}" \
        -kill \
        -r \
        -domain 'local' \
        -domain 'system' \
        -domain 'user'
    "${app[sudo]}" "${app[kill_all]}" 'Finder'
    koopa::alert_success 'Clean up was successful.'
    return 0
}

koopa::macos_flush_dns() { # {{{1
    # """
    # Flush DNS cache.
    # @note Updated 2021-11-16.
    # """
    local app
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    declare -A app=(
        [dscacheutil]="$(koopa::macos_locate_dscacheutil)"
        [kill_all]="$(koopa::macos_locate_kill_all)"
        [sudo]="$(koopa::locate_sudo)"
    )
    koopa::alert 'Flushing DNS.'
    "${app[sudo]}" "${app[dscacheutil]}" -flushcache
    "${app[sudo]}" "${app[kill_all]}" -HUP 'mDNSResponder'
    koopa::alert_success 'DNS flush was successful.'
    return 0
}
