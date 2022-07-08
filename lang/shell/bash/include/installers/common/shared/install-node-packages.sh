#!/usr/bin/env bash

# FIXME Rework this as isolated node environment instead.
# FIXME Don't attempt to version pin npm here? Install into main node
# app environment instead?
# FIXME Just set the NPM_CONFIG_PREFIX value to prefix here.

main() {
    # """
    # Install Node.js packages using npm.
    # @note Updated 2022-04-10.
    #
    # Node 'tldr' conflicts with Rust 'tealdeer'.
    #
    # @seealso
    # - npm help config
    # - npm help install
    # - npm config get prefix
    # """
    local app dict i pkgs
    koopa_assert_has_no_args "$#"
    # FIXME Rework this approach...
    koopa_activate_node
    declare -A app=(
        [node]="$(koopa_locate_node)"
        [npm1]="$(koopa_locate_npm)"
    )
    declare -A dict=(
        [npm_version]="$(koopa_variable 'node-npm')"
        [prefix]="${INSTALL_PREFIX:?}"
    )
    # FIXME Consider doing this in main node install call instead...
    # The npm install step will fail unless 'node' is in 'PATH'.
    koopa_add_to_path_start "$(koopa_dirname "${app[node]}")"
    koopa_alert "Pinning 'npm' to version ${dict[npm_version]}".
    "${app[npm1]}" install -g "npm@${dict[npm_version]}" &>/dev/null
    app[npm2]="${dict[prefix]}/bin/npm"
    koopa_assert_is_executable "${app[npm2]}"
    pkgs=(
        'bash-language-server'
        'gtop'
        'prettier'
    )
    for i in "${!pkgs[@]}"
    do
        local pkg pkg_lower version
        pkg="${pkgs[$i]}"
        pkg_lower="$(koopa_lowercase "$pkg")"
        version="$(koopa_variable "node-${pkg_lower}")"
        pkgs[$i]="${pkg}@${version}"
    done
    koopa_dl 'Packages' "${pkgs[*]}"
    "${app[npm2]}" install -g "${pkgs[@]}" 2>&1
    return 0
}
