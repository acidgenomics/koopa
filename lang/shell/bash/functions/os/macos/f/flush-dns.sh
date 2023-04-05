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
    app['sudo']="$(koopa_locate_sudo)"
    [[ -x "${app['dscacheutil']}" ]] || exit 1
    [[ -x "${app['kill_all']}" ]] || exit 1
    [[ -x "${app['sudo']}" ]] || exit 1
    koopa_alert 'Flushing DNS.'
    "${app['sudo']}" "${app['dscacheutil']}" -flushcache
    "${app['sudo']}" "${app['kill_all']}" -HUP 'mDNSResponder'
    koopa_alert_success 'DNS flush was successful.'
    return 0
}
