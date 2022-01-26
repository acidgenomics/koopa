#!/usr/bin/env bash

koopa:::install_mamba() { # {{{1
    # """
    # Update mamba.
    # @note Updated 2022-01-25.
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    koopa::assert_has_no_envs
    declare -A app=(
        [conda]="$(koopa::locate_conda)"
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
