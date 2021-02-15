#!/usr/bin/env bash

koopa::fedora_update_system() { # {{{1
    # """
    # Update Fedora.
    # @note Updated 2020-07-16.
    # """
    koopa::assert_has_no_args "$#"
    (
        sudo dnf update -y
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    return 0
}
