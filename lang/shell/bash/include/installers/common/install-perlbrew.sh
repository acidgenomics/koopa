#!/usr/bin/env bash

koopa:::install_perlbrew() { # {{{1
    # """
    # Install Perlbrew.
    # @note Updated 2022-01-24.
    # """
    local dict
    koopa::assert_has_no_args "$#"
    declare -A dict=(
        [prefix]="${INSTALL_PREFIX:?}"
    )
    dict[file]='install.sh'
    dict[url]='https://install.perlbrew.pl'
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::chmod 'u+x' "${dict[file]}"
    koopa::mkdir "${dict[prefix]}"
    export PERLBREW_ROOT="${dict[prefix]}"
    koopa::rm "${HOME:?}/.perlbrew"
    "./${dict[file]}"
}
