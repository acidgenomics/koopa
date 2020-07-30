#!/usr/bin/env bash

# shellcheck source=/dev/null
source "$(koopa header bash)"

koopa::roff() { # {{{1
    koopa::assert_is_installed ronn
    ronn --roff ./*.ronn
    koopa::mv -t 'man1' ./*.1
    return 0
}
