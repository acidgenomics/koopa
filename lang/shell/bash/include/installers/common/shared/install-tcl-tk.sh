#!/usr/bin/env bash

main() { # {{{
    # """
    # Install Tcl/Tk.
    # @note Updated 2022-04-20.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/tcl-tk.rb
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    dict[file]="tcl${dict[version]}-src.tar.gz"
    dict[url]="https://downloads.sourceforge.net/project/tcl/Tcl/\
${dict[version]}/${dict[file]}"
    return 0
}
