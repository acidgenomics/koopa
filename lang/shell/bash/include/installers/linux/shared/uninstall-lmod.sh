#!/usr/bin/env bash

main() {
    # """
    # Uninstall Lmod.
    # @note Updated 2022-04-07.
    # """
    koopa_assert_has_no_args "$#"
    if koopa_is_admin
    then
        koopa_rm --sudo \
            '/etc/profile.d/z00_lmod.csh' \
            '/etc/profile.d/z00_lmod.sh'
    fi
    return 0
}
