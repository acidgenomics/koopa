#!/usr/bin/env bash

koopa_macos_flush_dns() {
    # """
    # Flush DNS cache.
    # @note Updated 2021-11-16.
    # """
    local -A app
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    app['dscacheutil']="$(koopa_macos_locate_dscacheutil)"
    app['kill_all']="$(koopa_macos_locate_kill_all)"
    koopa_assert_is_executable "${app[@]}"
    koopa_alert 'Flushing DNS.'
    koopa_sudo "${app['dscacheutil']}" -flushcache
    koopa_sudo "${app['kill_all']}" -HUP 'mDNSResponder'
    koopa_alert_success 'DNS flush was successful.'
    return 0
}
