#!/usr/bin/env bash

main() {
    # """
    # Update mamba.
    # @note Updated 2022-07-14.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [conda]="$(koopa_locate_conda)"
    )
    [[ -x "${app[conda]}" ]] || return 1
    declare -A dict=(
        [name]='mamba'
        [version]="${INSTALL_VERSION:?}"
    )
    "${app[conda]}" install \
        --yes \
        --name='base' \
        --channel='conda-forge' \
        "${dict[name]}==${dict[version]}"
    return 0
}
