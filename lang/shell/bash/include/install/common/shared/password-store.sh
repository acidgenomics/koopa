#!/usr/bin/env bash

main() {
    # """
    # Install Password Store.
    # @note Updated 2022-07-18.
    # @seealso
    # - https://www.passwordstore.org/
    # - https://git.zx2c4.com/password-store/
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    [[ -x "${app[make]}" ]] || return 1
    declare -A dict=(
        [name]='password-store'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.xz"
    dict[url]="https://git.zx2c4.com/${dict[name]}/snapshot/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    PREFIX="${dict[prefix]}" "${app[make]}" install
    return 0
}
