#!/usr/bin/env bash

koopa_debian_set_timezone() {
    # """
    # Set local timezone.
    # @note Updated 2023-04-05.
    #
    # Inside Docker will see this issue:
    # System has not been booted with systemd as init system (PID 1). Can't
    # operate. Failed to connect to bus: Host is down.
    # """
    local -A app dict
    koopa_assert_has_args_le "$#" 1
    koopa_is_docker && return 0
    app['sudo']="$(koopa_locate_sudo)"
    app['timedatectl']="$(koopa_debian_locate_timedatectl)"
    koopa_assert_is_executable "${app[@]}"
    dict['tz']="${1:-}"
    [[ -z "${dict['tz']}" ]] && dict['tz']='America/New_York'
    koopa_alert "Setting local timezone to '${dict['tz']}'."
    "${app['sudo']}" "${app['timedatectl']}" set-timezone "${dict['tz']}"
    return 0
}
