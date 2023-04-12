#!/usr/bin/env bash

koopa_install_fish() {
    koopa_install_app \
        --name='fish' \
        "$@"
    # > koopa_enable_shell_for_all_users "$(koopa_bin_prefix)/fish"
    return 0
}
