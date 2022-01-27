#!/usr/bin/env bash

koopa:::install_node_packages() { # {{{1
    # """
    # Install Node.js packages using npm.
    # @note Updated 2022-01-26.
    #
    # @seealso
    # - npm help config
    # - npm help install
    # - npm config get prefix
    # """
    local app dict i pkgs
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [node]="$(koopa::locate_node)"
        [npm1]="$(koopa::locate_npm)"
    )
    declare -A dict=(
        [npm_version]="$(koopa::variable 'node-npm')"
        [prefix]="${INSTALL_PREFIX:?}"
    )
    koopa::configure_node
    koopa::activate_node
    # The npm install step will fail unless 'node' is in 'PATH'.
    koopa::add_to_path_start "$(koopa::dirname "${app[node]}")"
    koopa::alert "Pinning 'npm' to version ${dict[npm_version]}".
    "${app[npm1]}" install -g "npm@${dict[npm_version]}" &>/dev/null
    app[npm2]="${dict[prefix]}/bin/npm"
    koopa::assert_is_executable "${app[npm2]}"
    # NOTE 'tldr' conflicts with Rust 'tealdeer'.
    pkgs=(
        'bash-language-server'
        'gtop'
        'prettier'
    )
    for i in "${!pkgs[@]}"
    do
        local pkg pkg_lower version
        pkg="${pkgs[$i]}"
        pkg_lower="$(koopa::lowercase "$pkg")"
        version="$(koopa::variable "node-${pkg_lower}")"
        pkgs[$i]="${pkg}@${version}"
    done
    koopa::dl 'Packages' "${pkgs[*]}"
    "${app[npm2]}" install -g "${pkgs[@]}" &>/dev/null
    return 0
}
