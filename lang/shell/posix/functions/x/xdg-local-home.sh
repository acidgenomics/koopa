#!/bin/sh

_koopa_xdg_local_home() {
    # """
    # XDG local installation home.
    # @note Updated 2021-05-20.
    #
    # Not intended to be configurable with a global variable.
    #
    # @seealso
    # - https://www.freedesktop.org/software/systemd/man/file-hierarchy.html
    # """
    _koopa_print "${HOME:?}/.local"
    return 0
}
