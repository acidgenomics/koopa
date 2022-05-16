#!/bin/sh

koopa_is_tmux() {
    # """
    # Is current session running inside tmux?
    # @note Updated 2020-02-26.
    # """
    [ -n "${TMUX:-}" ]
}
