#!/usr/bin/env bash

koopa_brew_cleanup() {
    # """
    # Clean up Homebrew.
    # @note Updated 2023-05-09.
    # """
    local -A app
    koopa_assert_has_no_args "$#"
    app['brew']="$(koopa_locate_brew)"
    koopa_assert_is_executable "${app[@]}"
    koopa_alert 'Cleaning up.'
    "${app['brew']}" cleanup -s || true
    koopa_rm "$("${app['brew']}" --cache)"
    "${app['brew']}" autoremove || true
    return 0
}
