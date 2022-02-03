#!/usr/bin/env bash

koopa::configure_chemacs() { # {{{1
    # """
    # Configure chemacs.
    # @note Updated 2022-02-03.
    # """
    koopa::link_dotfile --opt --overwrite 'chemacs'
    return 0
}
