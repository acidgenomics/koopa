#!/usr/bin/env bash

koopa:::update_perlbrew() { # {{{1
    # """
    # Update Perlbrew.
    # @note Updated 2022-01-24.
    # """
    local app
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [perlbrew]="$(koopa::locate_perlbrew)"
    )
    koopa::activate_perlbrew
    "${app[perlbrew]}" self-upgrade
    return 0
}
