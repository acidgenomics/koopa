#!/usr/bin/env bash

koopa::unlink_app() { # {{{1
    # """
    # Unlink an application.
    # @note Updated 2021-08-14.
    # """
    local make_prefix
    koopa::assert_has_args "$#"
    make_prefix="$(koopa::make_prefix)"
    if koopa::is_macos
    then
        koopa::alert_note "Linking into '${make_prefix}' is not \
supported on macOS."
        return 0
    fi
    koopa::r_koopa 'cliUnlinkApp' "$@"
    return 0
}
