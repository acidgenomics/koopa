#!/usr/bin/env bash

koopa_debian_apt_enabled_repos() {
    # """
    # Get a list of enabled default apt repos.
    # @note Updated 2022-05-18.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
    )
    declare -A dict=(
        [file]="$(koopa_debian_apt_sources_file)"
        [os]="$(koopa_os_codename)"
    )
    dict[pattern]="^deb\s.+\s${dict[os]}\s.+$"
    dict[str]="$( \
        koopa_grep \
            --file="${dict[file]}" \
            --pattern="${dict[pattern]}" \
            --regex \
        | "${app[cut]}" -d ' ' -f '4-' \
    )"
    [[ -n "${dict[str]}" ]] || return 1
    koopa_print "${dict[str]}"
}
