#!/usr/bin/env bash

main() {
    # """
    # Install cheat.
    # @note Updated 2022-08-08.
    #
    # @seealso
    # - https://github.com/cheat/cheat/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/cheat.rb
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'go'
    declare -A app=(
        [go]="$(koopa_locate_go)"
    )
    [[ -x "${app[go]}" ]] || return 1
    declare -A dict=(
        [gopath]="$(koopa_init_dir 'go')"
        [name]='cheat'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[version]}.tar.gz"
    dict[url]="https://github.com/cheat/cheat/archive/refs/tags/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    export GOPATH="${dict[gopath]}"
    "${app[go]}" build -mod 'vendor' -o 'bin/cheat' './cmd/cheat'
    koopa_cp --target-directory="${dict[prefix]}" 'bin'
    koopa_chmod --recursive 'u+rw' "${dict[gopath]}"
    return 0
}
