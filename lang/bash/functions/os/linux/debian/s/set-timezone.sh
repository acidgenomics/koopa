#!/usr/bin/env bash

koopa_debian_set_timezone() {
    # """
    # Set local timezone.
    # @note Updated 2023-05-30.
    # """
    local -A app dict
    koopa_assert_has_args_le "$#" 1
    koopa_assert_is_admin
    koopa_linux_is_init_systemd || return 0
    app['timedatectl']="$(koopa_debian_locate_timedatectl)"
    koopa_assert_is_executable "${app[@]}"
    dict['tz']="${1:-}"
    [[ -z "${dict['tz']}" ]] && dict['tz']='America/New_York'
    koopa_alert "Setting local timezone to '${dict['tz']}'."
    koopa_sudo "${app['timedatectl']}" set-timezone "${dict['tz']}"
    return 0
}
