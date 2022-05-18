#!/usr/bin/env bash

koopa_r_shiny_run_app() {
    # """
    # Run an R/Shiny application.
    # @note Updated 2022-02-11.
    # """
    local app dict
    declare -A app=(
        [r]="$(koopa_locate_r)"
    )
    declare -A dict=(
        [prefix]="${1:-}"
    )
    [[ -z "${dict[prefix]}" ]] && dict[prefix]="${PWD:?}"
    koopa_assert_is_dir "${dict[prefix]}"
    dict[prefix]="$(koopa_realpath "${dict[prefix]}")"
    "${app[r]}" \
        --no-restore \
        --no-save \
        --quiet \
        -e "shiny::runApp('${dict[prefix]}')"
    return 0
}
