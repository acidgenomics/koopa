#!/usr/bin/env bash

main() {
    # """
    # Update mamba.
    # @note Updated 2022-01-25.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [conda]="$(koopa_locate_conda)"
    )
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
