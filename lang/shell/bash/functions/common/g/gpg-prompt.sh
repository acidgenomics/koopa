#!/usr/bin/env bash

# FIXME Need to locate gpg.

koopa_gpg_prompt() {
    # """
    # Force GPG to prompt for password.
    # @note Updated 2020-07-10.
    # Useful for building Docker images, etc. inside tmux.
    # """
    koopa_assert_has_no_args "$#"
    koopa_assert_is_installed 'gpg'
    printf '' | gpg -s
    return 0
}
