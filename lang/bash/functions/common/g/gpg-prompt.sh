#!/usr/bin/env bash

koopa_gpg_prompt() {
    # """
    # Force GPG to prompt for password.
    # @note Updated 2022-05-20.
    #
    # Useful for building Docker images, etc. inside tmux.
    # """
    local -A app
    koopa_assert_has_no_args "$#"
    app['gpg']="$(koopa_locate_gpg --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    printf '' | "${app['gpg']}" -s
    return 0
}
