#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install ShellCheck.
    # @note Updated 2022-01-19.
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [arch]="$(koopa_arch)"
        [name]='shellcheck'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    if koopa_is_macos
    then
        dict[os_id]='darwin'
    else
        dict[os_id]='linux'
    fi
    dict[file]="${dict[name]}-v${dict[version]}.${dict[os_id]}.\
${dict[arch]}.tar.xz"
    dict[url]="https://github.com/koalaman/${dict[name]}/releases/download/\
v${dict[version]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cp \
        "${dict[name]}-v${dict[version]}/${dict[name]}" \
        "${dict[prefix]}/bin/${dict[name]}"
    return 0
}
