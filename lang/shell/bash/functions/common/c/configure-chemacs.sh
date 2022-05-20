#!/usr/bin/env bash

koopa_configure_chemacs() {
    # """
    # Configure chemacs.
    # @note Updated 2022-04-04.
    # """
    koopa_link_dotfile --from-opt --overwrite 'chemacs' 'emacs.d'
    return 0
}
