#!/usr/bin/env bash

koopa_install_gawk() {
    koopa_install_app \
        --name='gawk' \
        "$@"
    (
        koopa_cd "$(koopa_man_prefix)/man1"
        koopa_ln 'gawk.1' 'awk.1'
    )
    return 0
}
