#!/bin/sh
# shellcheck disable=SC2039

# Note that these are defined primarily to catch errors in private scripts that
# are defined outside of the koopa package.

_koopa_defunct() {  # {{{1
    # """
    # Make a function defunct.
    # @note Updated 2020-01-16.
    # """
    local new
    new="${1:-}"
    local msg
    msg="Function is defunct."
    if [ -n "$new" ]
    then
        msg="${msg} Use '${new}' instead."
    fi
    _koopa_stop "${msg}"
}



_koopa_assert_is_darwin() {  # {{{1
    # """
    # @note Updated 2020-01-14.
    # """
    _koopa_defunct "_koopa_assert_is_macos"
}

_koopa_is_darwin() {  # {{{1
    # """
    # @note Updated 2020-01-14.
    # """
    _koopa_defunct "_koopa_is_macos"
}

_koopa_quiet_cd() {  # {{{1
    # """
    # @note Updated 2020-02-16.
    # """
    _koopa_defunct "_koopa_cd"
}

_koopa_quiet_expr() {  # {{{1
    # """
    # @note Updated 2020-02-16.
    # """
    _koopa_defunct "_koopa_expr"
}

_koopa_quiet_rm() {  # {{{1
    # """
    # @note Updated 2020-02-16.
    # """
    _koopa_defunct "_koopa_rm"
}

_koopa_update_profile() {  # {{{1
    # """
    # @note Updated 2020-02-15.
    # """
    _koopa_defunct "_koopa_update_etc_profile_d"
}

_koopa_update_shells() {  # {{{1
    # """
    # @note Updated 2020-02-11.
    # """
    _koopa_defunct "_koopa_enable_shell"
}
