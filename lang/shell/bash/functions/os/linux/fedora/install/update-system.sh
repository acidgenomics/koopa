#!/usr/bin/env bash

koopa::fedora_update_system() { # {{{1
    # """
    # Update Fedora.
    # @note Updated 2021-11-18.
    # """
    koopa::assert_has_no_args "$#"
    koopa::fedora_dnf update
    koopa::update_system
    return 0
}
