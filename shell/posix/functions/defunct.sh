#!/bin/sh
# shellcheck disable=SC2039

# Note that these are defined primarily to catch errors in private scripts that
# are defined outside of the koopa package.

_koopa_defunct() { # {{{1
    # """
    # Make a function defunct.
    # @note Updated 2020-02-18.
    # """
    local new
    new="${1:-}"
    local msg
    msg="Defunct."
    if [ -n "$new" ]
    then
        msg="${msg} Use '${new}' instead."
    fi
    _koopa_stop "${msg}"
}



_koopa_assert_is_darwin() { # {{{1
    # """
    # @note Updated 2020-01-14.
    # """
    _koopa_defunct "_koopa_assert_is_macos"

}

_koopa_conda_default_envs_prefix() { # {{{1
    # """
    # @note Updated 2020-02-19.
    # """
    _koopa_defunct "_koopa_conda_prefix"
}

_koopa_is_darwin() { # {{{1
    # """
    # @note Updated 2020-01-14.
    # """
    _koopa_defunct "_koopa_is_macos"

}

_koopa_is_matching_fixed() {  #{{{1
    # """
    # @note Updated 2020-04-29.
    # """
    _koopa_defunct "_koopa_str_match"
}

_koopa_is_matching_regex() {  #{{{1
    # """
    # @note Updated 2020-04-29.
    # """
    _koopa_defunct "_koopa_str_match_regex"
}

_koopa_prefix_mkdir() { # {{{1
    # """
    # @note Updated 2020-02-19.
    # """
    _koopa_defunct "_koopa_mkdir"
}

_koopa_quiet_cd() { # {{{1
    # """
    # @note Updated 2020-02-16.
    # """
    _koopa_defunct "_koopa_cd"
}

_koopa_quiet_expr() { # {{{1
    # """
    # @note Updated 2020-02-16.
    # """
    _koopa_defunct "_koopa_expr"
}

_koopa_quiet_rm() { # {{{1
    # """
    # @note Updated 2020-02-16.
    # """
    _koopa_defunct "_koopa_rm"
}

_koopa_update_profile() { # {{{1
    # """
    # @note Updated 2020-02-15.
    # """
    _koopa_defunct "_koopa_update_etc_profile_d"
}

_koopa_update_shells() { # {{{1
    # """
    # @note Updated 2020-02-11.
    # """
    _koopa_defunct "_koopa_enable_shell"
}
