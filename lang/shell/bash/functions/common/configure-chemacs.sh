#!/usr/bin/env bash

koopa_configure_chemacs() { # {{{1
    # """
    # Configure chemacs.
    # @note Updated 2022-02-03.
    # """
    koopa_link_dotfile --opt --overwrite 'chemacs' 'emacs.d'
    return 0
}
