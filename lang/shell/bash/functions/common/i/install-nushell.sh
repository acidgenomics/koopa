#!/usr/bin/env bash

koopa_install_nushell() {
    koopa_install_app \
        --name='nushell' \
        "$@"
    # > koopa_enable_shell_for_all_users "$(koopa_bin_prefix)/nu"
    return 0
}
