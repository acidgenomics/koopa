#!/usr/bin/env bash

koopa::roff() { # {{{1
    # """
    # Convert roff markdown files to ronn man pages.
    # @note Updated 2020-08-14.
    # """
    local koopa_prefix
    koopa::assert_is_installed 'ronn'
    koopa_prefix="$(koopa::prefix)"
    (
        koopa::cd "${koopa_prefix}/man"
        ronn --roff ./*.ronn
        koopa::mv -t 'man1' ./*.1
    )
    return 0
}
