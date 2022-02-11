#!/usr/bin/env bash

koopa::r_shiny_run_app() { # {{{1
    # """
    # Run an R/Shiny application.
    # @note Updated 2022-02-11.
    # """
    local app dict
    declare -A app=(
        [r]="$(koopa::locate_r)"
    )
    declare -A dict=(
        [prefix]="${1:-}"
    )
    [[ -z "${dict[prefix]}" ]] && dict[prefix]="${PWD:?}"
    koopa::assert_is_dir "${dict[prefix]}"
    dict[prefix]="$(koopa::realpath "${dict[prefix]}")"
    "${app[r]}" \
        --no-restore \
        --no-save \
        --quiet \
        -e "shiny::runApp('${dict[prefix]}')"
    return 0
}
