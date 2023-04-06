#!/usr/bin/env bash

koopa_debian_apt_enabled_repos() {
    # """
    # Get a list of enabled default apt repos.
    # @note Updated 2023-04-05.
    # """
    local -A app dict
    koopa_assert_has_no_args "$#"
    app['cut']="$(koopa_locate_cut --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['file']="$(koopa_debian_apt_sources_file)"
    dict['os']="$(koopa_debian_os_codename)"
    dict['pattern']="^deb\s.+\s${dict['os']}\s.+$"
    dict['str']="$( \
        koopa_grep \
            --file="${dict['file']}" \
            --pattern="${dict['pattern']}" \
            --regex \
        | "${app['cut']}" -d ' ' -f '4-' \
    )"
    [[ -n "${dict['str']}" ]] || return 1
    koopa_print "${dict['str']}"
    return 0
}
