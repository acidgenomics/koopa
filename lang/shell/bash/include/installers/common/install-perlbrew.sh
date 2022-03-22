#!/usr/bin/env bash

install_perlbrew() { # {{{1
    # """
    # Install Perlbrew.
    # @note Updated 2022-01-24.
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [prefix]="${INSTALL_PREFIX:?}"
    )
    dict[file]='install.sh'
    dict[url]='https://install.perlbrew.pl'
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_chmod 'u+x' "${dict[file]}"
    koopa_mkdir "${dict[prefix]}"
    export PERLBREW_ROOT="${dict[prefix]}"
    koopa_rm "${HOME:?}/.perlbrew"
    "./${dict[file]}"
}
