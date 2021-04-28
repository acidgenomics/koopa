#!/usr/bin/env bash

install_haskell_stack() { # {{{1
    # """
    # Install Haskell Stack.
    # @note Updated 2021-04-27.
    # @seealso
    # - https://docs.haskellstack.org/en/stable/install_and_upgrade/
    # """
    local file url xdg_bin_dir
    prefix="${INSTALL_PREFIX:?}"
    xdg_bin_dir="${HOME:?}/.local/bin"
    koopa::mkdir "$xdg_bin_dir"
    koopa::add_to_path_start "$xdg_bin_dir"
    file='stack.sh'
    url='https://get.haskellstack.org/'
    koopa::download "$url" "$file"
    chmod +x "$file"
    ./"${file}" -f -d "$prefix"
    return 0
}

install_haskell_stack "$@"
