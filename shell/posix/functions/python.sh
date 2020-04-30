#!/bin/sh
# shellcheck disable=SC2039

_koopa_pip_install() {  # {{{1
    # """
    # Internal pip install command.
    # @note Updated 2020-04-30.
    # """
    python3 \
        -m pip install \
        --no-warn-script-location \
        "$@"
    return 0
}
