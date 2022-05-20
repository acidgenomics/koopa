#!/usr/bin/env bash

main() {
    # """
    # Install Pandoc binary.
    # @note Updated 2022-05-14.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [dpkg]="$(koopa_debian_locate_dpkg)"
        [sudo]="$(koopa_locate_sudo)"
    )
    declare -A dict=(
        [arch]="$(koopa_arch2)"
        [version]="${INSTALL_VERSION:?}"
        [name]='pandoc'
    )
    dict[file]="${dict[name]}-${dict[version]}-1-${dict[arch]}.deb"
    dict[url]="https://github.com/jgm/${dict[name]}/releases/download/\
${dict[version]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    "${app[sudo]}" "${app[dpkg]}" -i "${dict[file]}"
    return 0
}
