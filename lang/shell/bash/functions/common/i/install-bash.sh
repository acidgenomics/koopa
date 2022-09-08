#!/usr/bin/env bash

koopa_install_bash() {
    koopa_install_app \
        --name='bash' \
        "$@"
    koopa_enable_shell_for_all_users "$(koopa_bin_prefix)/bash"
    return 0
}
