#!/usr/bin/env bash

_koopa_debian_apt_enable_deb_src() {
    # """
    # Enable 'deb-src' source packages.
    # @note Updated 2023-05-10.
    # """
    local -A app dict
    _koopa_assert_has_args_le "$#" 1
    _koopa_assert_is_admin
    app['sed']="$(_koopa_locate_sed --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['file']="${1:-}"
    [[ -z "${dict['file']}" ]] && \
        dict['file']="$(_koopa_debian_apt_sources_file)"
    _koopa_assert_is_file "${dict['file']}"
    _koopa_alert "Enabling Debian sources in '${dict['file']}'."
    if ! _koopa_file_detect_regex \
        --file="${dict['file']}" \
        --pattern='^# deb-src '
    then
        _koopa_alert_note "No lines to uncomment in '${dict['file']}'."
        return 0
    fi
    _koopa_sudo \
        "${app['sed']}" \
            -E \
            -i.bak \
            's/^# deb-src /deb-src /' \
            "${dict['file']}"
    _koopa_debian_apt_get update
    return 0
}
