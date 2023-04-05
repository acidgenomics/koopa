#!/usr/bin/env bash

koopa_roff() {
    # """
    # Convert roff markdown files to ronn man pages.
    # @note Updated 2022-07-29.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['ronn']="$(koopa_locate_ronn)"
    )
    [[ -x "${app['ronn']}" ]] || exit 1
    declare -A dict=(
        ['man_prefix']="$(koopa_man_prefix)"
    )
    (
        koopa_cd "${dict['man_prefix']}/man1-ronn"
        "${app['ronn']}" --roff ./*'.ronn'
        koopa_mv --target-directory="${dict['man_prefix']}/man1" ./*'.1'
    )
    return 0
}
