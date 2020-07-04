#!/bin/sh
# shellcheck disable=SC2039

koopa::pip_install() { # {{{1
    # """
    # Internal pip install command.
    # @note Updated 2020-07-03.
    # """
    koopa::assert_has_args "$#"
    local python
    python="python3"
    koopa::assert_is_installed "$python"
    "$python" \
        -m pip install \
        --no-warn-script-location \
        "$@"
    return 0
}
