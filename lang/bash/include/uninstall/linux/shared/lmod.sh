#!/usr/bin/env bash

main() {
    # """
    # Uninstall Lmod system configuration files.
    # @note Updated 2023-04-03.
    # """
    [[ -f '/etc/profile.d/z00_lmod.sh' ]] || return 0
    koopa_assert_is_admin
    koopa_rm --sudo \
        '/etc/profile.d/z00_lmod.csh' \
        '/etc/profile.d/z00_lmod.sh'
    return 0
}
