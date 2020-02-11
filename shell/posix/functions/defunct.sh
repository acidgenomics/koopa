#!/bin/sh
# shellcheck disable=SC2039

# Note that these are defined primarily to catch errors in private scripts that
# are defined outside of the koopa package.

_koopa_defunct() {
    # """
    # Make a function defunct.
    # Updated 2020-01-16.
    # """
    local new
    new="${1:?}"
    _koopa_stop "Function is defunct. Use '${new}' instead."
}



_koopa_assert_is_darwin() {
    # """
    # Updated 2020-01-14.
    # """
    _koopa_defunct "_koopa_assert_is_macos"
}

_koopa_is_darwin() {
    # """
    # Updated 2020-01-14.
    # """
    _koopa_defunct "_koopa_is_macos"
}

_koopa_update_shells() {
    # """
    # Updated 2020-02-11.
    # """
    _koopa_defunct "_koopa_enable_shell"
}
