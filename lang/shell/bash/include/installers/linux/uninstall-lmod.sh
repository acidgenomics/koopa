#!/usr/bin/env bash

# FIXME We may need to remove the prefix here.

main() { # {{{1
    # """
    # Uninstall Lmod.
    # @note Updated 2022-04-07.
    # """
    koopa_rm --sudo \
        '/etc/profile.d/z00_lmod.csh' \
        '/etc/profile.d/z00_lmod.sh'
    return 0
}
