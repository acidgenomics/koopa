#!/usr/bin/env bash

koopa_macos_clean_launch_services() {
    # """
    # Clean launch services.
    # @note Updated 2021-11-16.
    # """
    local app
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [kill_all]="$(koopa_macos_locate_kill_all)"
        [lsregister]="$(koopa_macos_locate_lsregister)"
        [sudo]="$(koopa_locate_sudo)"
    )
    koopa_alert "Cleaning LaunchServices 'Open With' menu."
    "${app[lsregister]}" \
        -kill \
        -r \
        -domain 'local' \
        -domain 'system' \
        -domain 'user'
    "${app[sudo]}" "${app[kill_all]}" 'Finder'
    koopa_alert_success 'Clean up was successful.'
    return 0
}
