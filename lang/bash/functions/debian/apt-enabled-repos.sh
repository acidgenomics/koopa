#!/usr/bin/env bash

_koopa_debian_apt_enabled_repos() {
    # """
    # Get a list of enabled default apt repos.
    # @note Updated 2023-04-05.
    # """
    local -A app dict
    _koopa_assert_has_no_args "$#"
    app['cut']="$(_koopa_locate_cut --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['file']="$(_koopa_debian_apt_sources_file)"
    dict['os']="$(_koopa_debian_os_codename)"
    dict['pattern']="^deb\s.+\s${dict['os']}\s.+$"
    dict['str']="$( \
        _koopa_grep \
            --file="${dict['file']}" \
            --pattern="${dict['pattern']}" \
            --regex \
        | "${app['cut']}" -d ' ' -f '4-' \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    _koopa_print "${dict['str']}"
    return 0
}
