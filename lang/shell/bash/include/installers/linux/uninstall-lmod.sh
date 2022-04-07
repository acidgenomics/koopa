#!/usr/bin/env bash

linux_uninstall_lmod() { # {{{1
    koopa_rm --sudo \
        '/etc/profile.d/z00_lmod.csh' \
        '/etc/profile.d/z00_lmod.sh'
    return 0
}
