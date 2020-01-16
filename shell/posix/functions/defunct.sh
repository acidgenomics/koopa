#!/bin/sh
# shellcheck disable=SC2039

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

_koopa_prefix_chgrp() {
    # """
    # Updated 2020-01-16.
    # """
    _koopa_defunct "_koopa_chgrp"
}

_koopa_reset_prefix_permissions() {
    # """
    # Updated 2020-01-16.
    # """
    _koopa_defunct "_koopa_prepare_prefix"
}
