#!/usr/bin/env bash

# [2021-05-27] macOS success.

koopa::install_haskell_stack() { # {{{1
    koopa::install_app \
        --name='haskell-stack' \
        --name-fancy='Haskell Stack' \
        --no-link \
        "$@"
}

koopa:::install_haskell_stack() { # {{{1
    # """
    # Install Haskell Stack.
    # @note Updated 2021-05-27.
    # @seealso
    # - https://docs.haskellstack.org/en/stable/install_and_upgrade/
    # """
    local file url xdg_bin_dir
    prefix="${INSTALL_PREFIX:?}"
    xdg_bin_dir="$(koopa::xdg_local_home)/bin"
    koopa::mkdir "$xdg_bin_dir"
    koopa::add_to_path_start "$xdg_bin_dir"
    file='stack.sh'
    url='https://get.haskellstack.org/'
    koopa::download "$url" "$file"
    koopa::chmod +x "$file"
    koopa::mkdir "${prefix}/bin"
    ./"${file}" -f -d "${prefix}/bin"
    return 0
}
