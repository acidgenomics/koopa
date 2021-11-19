#!/usr/bin/env bash

koopa:::update_python_packages() { # {{{1
    # """
    # Update all pip packages.
    # @note Updated 2021-11-19.
    # @seealso
    # - https://github.com/pypa/pip/issues/59
    # - https://stackoverflow.com/questions/2720014
    # """
    local app pkgs
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [cut]="$(koopa::locate_cut)"
    )
    readarray -t pkgs <<< "$( \
        "$(koopa::python_pip_outdated)" \
        | "${app[cut]}" -d '=' -f 1 \
    )"
    if koopa::is_array_empty "${pkgs[@]:-}"
    then
        koopa::alert_success 'All Python packages are current.'
        return 0
    fi
    koopa::python_pip_install "${pkgs[@]}"
    return 0
}
