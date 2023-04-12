#!/usr/bin/env bash

koopa_install_dash() {
    koopa_install_app \
        --name='dash' \
        "$@"
    koopa_enable_shell_for_all_users "$(koopa_bin_prefix)/dash"
    return 0
}
