#!/usr/bin/env bash

koopa_jekyll_serve() {
    # """
    # Render Jekyll website.
    # Updated 2021-12-08.
    # """
    local app dict
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [bundle]="$(koopa_locate_bundle)"
    )
    declare -A dict=(
        [prefix]="${1:-}"
    )
    [[ -z "${dict[prefix]}" ]] && dict[prefix]="${PWD:?}"
    dict[prefix]="$(koopa_realpath "${dict[prefix]}")"
    koopa_alert "Serving Jekyll website in '${dict[prefix]}'."
    (
        koopa_cd "${dict[prefix]}"
        koopa_assert_is_file 'Gemfile'
        if [[ -f 'Gemfile.lock' ]]
        then
            "${app[bundle]}" update --bundler
        fi
        "${app[bundle]}" install
        "${app[bundle]}" exec jekyll serve
    )
    return 0
}
