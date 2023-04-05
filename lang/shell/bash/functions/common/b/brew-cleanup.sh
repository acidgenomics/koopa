#!/usr/bin/env bash

koopa_brew_cleanup() {
    # """
    # Clean up Homebrew.
    # @note Updated 2022-07-15.
    # """
    local -A app
    koopa_assert_has_no_args "$#"
    app['brew']="$(koopa_locate_brew)"
    [[ -x "${app['brew']}" ]] || exit 1
    "${app['brew']}" cleanup -s || true
    koopa_rm "$("${app['brew']}" --cache)"
    "${app['brew']}" autoremove || true
    return 0
}
