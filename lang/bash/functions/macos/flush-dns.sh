#!/usr/bin/env bash

_koopa_macos_flush_dns() {
    # """
    # Flush DNS cache.
    # @note Updated 2021-11-16.
    # """
    local -A app
    _koopa_assert_has_no_args "$#"
    _koopa_assert_is_admin
    app['dscacheutil']="$(_koopa_macos_locate_dscacheutil)"
    app['kill_all']="$(_koopa_macos_locate_kill_all)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_alert 'Flushing DNS.'
    _koopa_sudo "${app['dscacheutil']}" -flushcache
    _koopa_sudo "${app['kill_all']}" -HUP 'mDNSResponder'
    _koopa_alert_success 'DNS flush was successful.'
    return 0
}
