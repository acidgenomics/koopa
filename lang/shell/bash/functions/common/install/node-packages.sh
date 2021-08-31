#!/usr/bin/env bash

koopa::install_node_packages() { # {{{1
    # """
    # Install Node.js packages using npm.
    # @note Updated 2021-06-17.
    # @seealso
    # - npm help config
    # - npm help install
    # - npm config get prefix
    # """
    local name_fancy npm npm_version pkg pkg_lower pkgs prefix version
    koopa::assert_has_no_args "$#"
    koopa::assert_has_no_envs
    koopa::configure_node
    koopa::activate_node
    name_fancy='Node.js packages'
    prefix="$(koopa::node_packages_prefix)"
    npm='npm'
    koopa::assert_is_installed "$npm"
    koopa::install_start "$name_fancy" "$prefix"
    # Ensure npm is configured to desired version.
    npm_version="$(koopa::variable 'node-npm')"
    npm install -g "npm@${npm_version}"
    koopa::activate_node
    npm="${prefix}/bin/npm"
    koopa::assert_is_executable "$npm"
    pkgs=("$@")
    if [[ "${#pkgs[@]}" -eq 0 ]]
    then
        # 'tldr' conflicts with Rust 'tealdeer'.
        pkgs=(
            'gtop'
        )
        for i in "${!pkgs[@]}"
        do
            pkg="${pkgs[$i]}"
            pkg_lower="$(koopa::lowercase "$pkg")"
            version="$(koopa::variable "node-${pkg_lower}")"
            pkgs[$i]="${pkg}@${version}"
        done
    fi
    "$npm" install -g "${pkgs[@]}"
    koopa::install_success "$name_fancy" "$prefix"
    return 0
}

koopa::uninstall_node_packages() { # {{{1
    # """
    # Uninstall Node.js packages.
    # @note Updated 2021-06-17.
    # """
    koopa::uninstall_app \
        --name='node-packages' \
        --name-fancy='Node.js packages' \
        --no-link \
        "$@"
    }

koopa::update_node_packages() { # {{{1
    # """
    # Update Node.js packages.
    # @note Updated 2021-08-31.
    # """
    koopa::install_node_packages "$@"
}
