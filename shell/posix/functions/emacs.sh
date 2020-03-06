#!/bin/sh
# shellcheck disable=SC2039

_koopa_spacemacs_update_layers() {  # {{{1
    # """
    # Update/install spacemacs layers non-interatively.
    # @note Updated 2020-03-06.
    #
    # Potentially useful: 'emacs --no-window-system'
    # """
    _koopa_assert_is_installed emacs
    emacs \
        --batch -l ~/.emacs.d/init.el \
        --eval="(configuration-layer/update-packages t)"
    return 0
}
