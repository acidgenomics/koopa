#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install chezmoi.
    # @note Updated 2022-05-10.
    #
    # @seealso
    # - https://www.chezmoi.io/
    # - https://github.com/twpayne/chezmoi
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/chezmoi.rb
    # - https://ports.macports.org/port/chezmoi/details/
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'go'
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [name]='chezmoi'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="v${dict[version]}.tar.gz"
    dict[url]="https://github.com/twpayne/chezmoi/archive/\
refs/tags/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    koopa_mkdir "${dict[prefix]}/bin"
    "${app[make]}" install \
        GO_LDFLAGS="-X main.version=${dict[version]}" \
        PREFIX="${dict[prefix]}"
    koopa_configure_chezmoi
    return 0
}
