#!/usr/bin/env bash

koopa_python_pip_outdated() {
    # """
    # List oudated pip packages.
    # @note Updated 2022-06-15.
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
    [[ -z "${app[python]}" ]] && app[python]="$(koopa_locate_python)"
    [[ -x "${app[python]}" ]] || return 1
    declare -A dict=(
        [version]="$(koopa_get_version "${app[python]}")"
    )
    dict[prefix]="$(koopa_python_packages_prefix "${dict[version]}")"
    dict[str]="$( \
        "${app[python]}" -m pip list \
            --format 'freeze' \
            --outdated \
            --path "${dict[prefix]}" \
    )"
    [[ -n "${dict[str]}" ]] || return 0
    koopa_print "${dict[str]}"
    return 0
}
