#!/usr/bin/env bash

# FIXME Consider installing into libexec and then linking...

main() {
    # """
    # Install Node.js package using npm.
    # @note Updated 2022-07-08.
    #
    # @seealso
    # - npm help config
    # - npm help install
    # - npm config get prefix
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [node]="$(koopa_locate_node)"
        [npm]="$(koopa_locate_npm)"
    )
    [[ -x "${app[npm]}" ]] || return 1
    app[node]="$(koopa_realpath "${app[node]}")"
    declare -A dict=(
        [name]="${INSTALL_NAME:?}"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    koopa_add_to_path_start "$(koopa_dirname "${app[node]}")"
    export NPM_CONFIG_PREFIX="${dict[prefix]}"
    "${app[npm]}" install \
        --location='global' \
        --no-audit \
        --no-fund \
        "${dict[name]}@${dict[version]}" \
        2>&1
    return 0
}
