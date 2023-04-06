#!/usr/bin/env bash

koopa_macos_finder_hide() {
    # """
    # Hide files from view in the Finder.
    # @note Updated 2022-05-20.
    # """
    local -A app
    koopa_assert_has_args "$#"
    app['setfile']="$(koopa_macos_locate_setfile)"
    koopa_assert_is_executable "${app[@]}"
    koopa_assert_is_existing "$@"
    "${app['setfile']}" -a V "$@"
    return 0
}
