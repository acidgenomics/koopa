#!/usr/bin/env bash

_koopa_macos_clean_launch_services() {
    # """
    # Clean launch services.
    # @note Updated 2025-09-15.
    #
    # @seealso
    # https://discussions.apple.com/thread/251735453
    # """
    local -A app
    _koopa_assert_has_no_args "$#"
    _koopa_assert_is_admin
    app['kill_all']="$(_koopa_macos_locate_kill_all)"
    app['lsregister']="$(_koopa_macos_locate_lsregister)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_alert "Cleaning LaunchServices 'Open With' menu."
    "${app['lsregister']}" \
        -kill \
        -r \
        -domain 'local' \
        -domain 'system' \
        -domain 'user'
    _koopa_sudo "${app['lsregister']}" \
        -kill \
        -lint \
        -seed \
        -f \
        -r \
        -v \
        -dump \
        -domain 'local' \
        -domain 'network' \
        -domain 'system' \
        -domain 'user'
    _koopa_sudo "${app['kill_all']}" 'Finder'
    _koopa_sudo "${app['kill_all']}" 'Dock'
    _koopa_alert_success 'Clean up was successful.'
    return 0
}
