#!/usr/bin/env bash

koopa::configure_chemacs() { # {{{1
    # """
    # Configure chemacs.
    # @note Updated 2022-02-01.
    # """
    koopa::link_dotfile --force --opt 'chemacs'
    return 0
}
