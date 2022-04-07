#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install Node.js packages using npm.
    # @note Updated 2022-04-06.
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
    koopa_activate_node
    declare -A app=(
        [brew]="$(koopa_locate_brew --allow-missing)"
        [node]="$(koopa_locate_node)"
        [npm1]="$(koopa_locate_npm)"
    )
    declare -A dict=(
        [npm_version]="$(koopa_variable 'node-npm')"
        [prefix]="${INSTALL_PREFIX:?}"
    )
    # The npm install step will fail unless 'node' is in 'PATH'.
    koopa_add_to_path_start "$(koopa_dirname "${app[node]}")"
    koopa_alert "Pinning 'npm' to version ${dict[npm_version]}".
    "${app[npm1]}" install -g "npm@${dict[npm_version]}" &>/dev/null
    app[npm2]="${dict[prefix]}/bin/npm"
    koopa_assert_is_executable "${app[npm2]}"
    pkgs=(
        'bash-language-server'
    )
    if [[ ! -x "${app[brew]}" ]]
    then
        pkgs+=(
            'gtop'
            'prettier'
        )
    fi
    for i in "${!pkgs[@]}"
    do
        local pkg pkg_lower version
        pkg="${pkgs[$i]}"
        pkg_lower="$(koopa_lowercase "$pkg")"
        version="$(koopa_variable "node-${pkg_lower}")"
        pkgs[$i]="${pkg}@${version}"
    done
    koopa_dl 'Packages' "${pkgs[*]}"
    "${app[npm2]}" install -g "${pkgs[@]}" &>/dev/null
    return 0
}
