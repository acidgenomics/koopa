#!/usr/bin/env bash

koopa:::install_shellcheck() { # {{{1
    # """
    # Install ShellCheck.
    # @note Updated 2022-01-06.
    # """
    local dict
    koopa::assert_has_no_args "$#"
    declare -A dict=(
        [arch]="$(koopa::arch)"
        [name]='shellcheck'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    if koopa::is_macos
    then
        dict[os_id]='darwin'
    else
        dict[os_id]='linux'
    fi
    dict[file]="${dict[name]}-v${dict[version]}.${dict[os_id]}.\
${dict[arch]}.tar.xz"
    dict[url]="https://github.com/koalaman/${dict[name]}/releases/download/\
v${dict[version]}/${dict[file]}"
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::extract "${dict[file]}"
    # FIXME Need to ensure that 'koopa::cp' creates bin directory automatically.
    koopa::mkdir "${dict[prefix]}/bin"
    koopa::cp \
        "${dict[name]}-v${dict[version]}/${dict[name]}" \
        "${dict[prefix]}/bin/${dict[name]}"
    return 0
}
