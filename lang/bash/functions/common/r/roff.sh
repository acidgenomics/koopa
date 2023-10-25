#!/usr/bin/env bash

# FIXME Rework this to nest the ronn files in man1?
# FIXME Need to search for ronn files recursively instead.

koopa_roff() {
    # """
    # Convert roff markdown files to ronn man pages.
    # @note Updated 2023-10-25.
    # """
    local -A app dict
    koopa_assert_has_no_args "$#"
    app['ronn']="$(koopa_locate_ronn)"
    koopa_assert_is_executable "${app[@]}"
    dict['man_prefix']="$(koopa_man_prefix)"
    (
        koopa_cd "${dict['man_prefix']}/man1-ronn"
        "${app['ronn']}" --roff ./*'.ronn'
        koopa_mv --target-directory="${dict['man_prefix']}/man1" ./*'.1'
    )
    return 0
}
