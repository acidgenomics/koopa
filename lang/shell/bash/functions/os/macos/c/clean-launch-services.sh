#!/usr/bin/env bash

koopa_macos_clean_launch_services() {
    # """
    # Clean launch services.
    # @note Updated 2023-05-01.
    # """
    local -A app
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    app['kill_all']="$(koopa_macos_locate_kill_all)"
    app['lsregister']="$(koopa_macos_locate_lsregister)"
    koopa_assert_is_executable "${app[@]}"
    koopa_alert "Cleaning LaunchServices 'Open With' menu."
    "${app['lsregister']}" \
        -kill \
        -r \
        -domain 'local' \
        -domain 'system' \
        -domain 'user'
    koopa_sudo "${app['kill_all']}" 'Finder'
    koopa_alert_success 'Clean up was successful.'
    return 0
}
