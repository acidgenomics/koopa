#!/usr/bin/env bash

koopa::fedora_update_system() { # {{{1
    # """
    # Update Fedora.
    # @note Updated 2021-06-16.
    # """
    local tee
    tee="$(koopa::locate_tee)"
    koopa::assert_has_no_args "$#"
    (
        koopa::fedora_dnf update
    ) 2>&1 | "$tee" "$(koopa::tmp_log_file)"
    return 0
}
