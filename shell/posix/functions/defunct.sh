#!/bin/sh
# shellcheck disable=SC2039

_koopa_defunct() {                                                        # {{{1
    local new
    new="${1:?}"
    _koopa_stop "Function is defunct. Use '${new}' instead."
}



_koopa_assert_is_darwin() {                                               # {{{1
    # """
    # Updated 2020-01-14.
    # """
    _koopa_defunct "_koopa_assert_is_macos"
}

_koopa_is_darwin() {                                                      # {{{1
    # """
    # Updated 2020-01-14.
    # """
    _koopa_defunct "_koopa_is_macos"
}
