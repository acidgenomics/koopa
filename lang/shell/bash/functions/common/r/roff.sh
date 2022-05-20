#!/usr/bin/env bash

koopa_roff() {
    # """
    # Convert roff markdown files to ronn man pages.
    # @note Updated 2022-02-17.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [ronn]="$(koopa_locate_ronn)"
    )
    declare -A app=(
        [man_prefix]="$(koopa_man_prefix)"
    )
    (
        koopa_cd "${dict[man_prefix]}"
        "${app[ronn]}" --roff ./*'.ronn'
        koopa_mv --target-directory='man1' ./*'.1'
    )
    return 0
}
