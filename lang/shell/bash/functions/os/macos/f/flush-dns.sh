#!/usr/bin/env bash

koopa_macos_flush_dns() {
    # """
    # Flush DNS cache.
    # @note Updated 2021-11-16.
    # """
    local app
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [dscacheutil]="$(koopa_macos_locate_dscacheutil)"
        [kill_all]="$(koopa_macos_locate_kill_all)"
        [sudo]="$(koopa_locate_sudo)"
    )
    [[ -x "${app['dscacheutil']}" ]] || return 1
    [[ -x "${app['kill_all']}" ]] || return 1
    [[ -x "${app['sudo']}" ]] || return 1
    koopa_alert 'Flushing DNS.'
    "${app['sudo']}" "${app['dscacheutil']}" -flushcache
    "${app['sudo']}" "${app['kill_all']}" -HUP 'mDNSResponder'
    koopa_alert_success 'DNS flush was successful.'
    return 0
}
