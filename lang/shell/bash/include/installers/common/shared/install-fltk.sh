#!/usr/bin/env bash

main() {
    # """
    # Install FLTK.
    # @note Updated 2022-04-10.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/fltk.rb
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
    )
    declare -A dict=(
        [name]='fltk'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}-source.tar.gz"
    dict[url]="https://www.${dict[name]}.org/pub/${dict[name]}/\
${dict[version]}/${dict[file]}"


    return 0
}
