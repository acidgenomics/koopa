#!/usr/bin/env bash

koopa:::install_haskell_stack() { # {{{1
    # """
    # Install Haskell Stack.
    # @note Updated 2021-11-30.
    # @seealso
    # - https://docs.haskellstack.org/en/stable/install_and_upgrade/
    # """
    local dict
    koopa::assert_has_no_args "$#"
    declare -A dict=(
        [prefix]="${INSTALL_PREFIX:?}"
    )
    dict[xdg_bin_dir]="$(koopa::xdg_local_home)/bin"
    koopa::mkdir "${dict[xdg_bin_dir]}"
    koopa::add_to_path_start "${dict[xdg_bin_dir]}"
    dict[file]='stack.sh'
    dict[url]='https://get.haskellstack.org/'
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::chmod 'u+x' "${dict[file]}"
    koopa::mkdir "${dict[prefix]}/bin"
    ./"${dict[file]}" -f -d "${dict[prefix]}/bin"
    return 0
}
