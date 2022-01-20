#!/usr/bin/env bash

koopa::python_pip_outdated() { # {{{1
    # """
    # List oudated pip packages.
    # @note Updated 2022-01-20.
    #
    # Requesting 'freeze' format will return '<pkg>==<version>'.
    #
    # @seealso
    # - https://pip.pypa.io/en/stable/cli/pip_list/
    # """
    local app dict
    declare -A app=(
        [python]="${1:-}"
    )
    [[ -z "${app[python]}" ]] && app[python]="$(koopa::locate_python)"
    koopa::assert_is_installed "${app[python]}"
    declare -A dict=(
        [version]="$(koopa::get_version "${app[python]}")"
    )
    # FIXME Rework this, passing in Python directly instead.
    dict[prefix]="$(koopa::python_packages_prefix "${dict[version]}")"
    dict[str]="$( \
        "${app[python]}" -m pip list \
            --format 'freeze' \
            --outdated \
            --path "${dict[prefix]}" \
    )"
    [[ -n "${dict[str]}" ]] || return 0
    koopa::print "${dict[str]}"
    return 0
}
