#!/bin/sh
# shellcheck disable=SC2039

_koopa_pip_install() { # {{{1
    # """
    # Internal pip install command.
    # @note Updated 2020-06-30.
    # """
    _koopa_assert_has_args "$#"
    local python
    python="python3"
    _koopa_is_installed "$python" || return 1
    "$python" \
        -m pip install \
        --no-warn-script-location \
        "$@"
    return 0
}
