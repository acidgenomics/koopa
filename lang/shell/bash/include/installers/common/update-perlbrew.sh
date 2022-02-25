#!/usr/bin/env bash

update_perlbrew() { # {{{1
    # """
    # Update Perlbrew.
    # @note Updated 2022-01-24.
    # """
    local app
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [perlbrew]="$(koopa_locate_perlbrew)"
    )
    koopa_activate_perlbrew
    "${app[perlbrew]}" self-upgrade
    return 0
}
