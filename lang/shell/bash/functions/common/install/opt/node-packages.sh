#!/usr/bin/env bash

koopa::install_node_packages() { # {{{1
    koopa:::install_app \
        --name-fancy='Node packages' \
        --name='node-packages' \
        --no-link \
        --no-prefix-check \
        --prefix="$(koopa::node_packages_prefix)" \
        "$@"
}

koopa:::install_node_packages() { # {{{1
    # """
    # Install Node.js packages using npm.
    # @note Updated 2021-09-17.
    # @seealso
    # - npm help config
    # - npm help install
    # - npm config get prefix
    # """
    local node npm npm_version pkg pkg_lower pkgs prefix version
    koopa::assert_has_no_args "$#"
    prefix="${INSTALL_PREFIX:?}"
    node="$(koopa::locate_node)"
    npm="$(koopa::locate_npm)"
    koopa::configure_node
    koopa::activate_node
    # The npm install step will fail unless 'node' is in 'PATH'.
    koopa::add_to_path_start "$(koopa::dirname "$node")"
    # Ensure npm is configured to desired version.
    npm_version="$(koopa::variable 'node-npm')"
    "$npm" install -g "npm@${npm_version}"
    npm="${prefix}/bin/npm"
    koopa::assert_is_executable "$npm"
    pkgs=("$@")
    if [[ "${#pkgs[@]}" -eq 0 ]]
    then
        # NOTE 'tldr' conflicts with Rust 'tealdeer'.
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
    return 0
}

koopa::uninstall_node_packages() { # {{{1
    # """
    # Uninstall Node.js packages.
    # @note Updated 2021-06-17.
    # """
    koopa:::uninstall_app \
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
