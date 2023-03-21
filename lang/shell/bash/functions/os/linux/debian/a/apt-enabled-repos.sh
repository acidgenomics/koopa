#!/usr/bin/env bash

koopa_debian_apt_enabled_repos() {
    # """
    # Get a list of enabled default apt repos.
    # @note Updated 2023-01-10.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['cut']="$(koopa_locate_cut --allow-system)"
    )
    [[ -x "${app['cut']}" ]] || return 1
    declare -A dict=(
        ['file']="$(koopa_debian_apt_sources_file)"
        ['os']="$(koopa_debian_os_codename)"
    )
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
}
