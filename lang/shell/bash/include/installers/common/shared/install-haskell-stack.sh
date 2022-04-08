#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install Haskell Stack.
    # @note Updated 2022-03-29.
    #
    # @seealso
    # - https://docs.haskellstack.org/en/stable/install_and_upgrade/
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [prefix]="${INSTALL_PREFIX:?}"
    )
    dict[xdg_bin_dir]="$(koopa_xdg_local_home)/bin"
    koopa_mkdir "${dict[xdg_bin_dir]}"
    koopa_add_to_path_start "${dict[xdg_bin_dir]}"
    dict[file]='stack.sh'
    dict[url]='https://get.haskellstack.org/'
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_chmod 'u+x' "${dict[file]}"
    koopa_mkdir "${dict[prefix]}/bin"
    ./"${dict[file]}" -f -d "${dict[prefix]}/bin"
    koopa_rm "${HOME:?}/.stack"
    return 0
}
