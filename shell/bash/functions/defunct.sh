#!/usr/bin/env bash

# Note that these are defined primarily to catch errors in private scripts that
# are defined outside of the koopa package.

koopa::defunct() { # {{{1
    # """
    # Make a function defunct.
    # @note Updated 2020-02-18.
    # """
    local msg new
    new="${1:-}"
    msg='Defunct.'
    if [[ -n "$new" ]]
    then
        msg="${msg} Use '${new}' instead."
    fi
    koopa::stop "${msg}"
}

_koopa_activate_conda_create_env() { # {{{1
    # """
    # @note Updated 2020-07-20.
    # """
    koopa::defunct koopa::activate_conda_env
}

_koopa_conda_create_env() { # {{{1
    # """
    # @note Updated 2020-07-20.
    # """
    koopa::defunct koopa::conda_create_env
}

_koopa_conda_remove_env() { # {{{1
    # """
    # @note Updated 2020-07-20.
    # """
    koopa::defunct koopa::conda_remove_env
}

koopa::is_darwin() { # {{{1
    # """
    # @note Updated 2020-01-14.
    # """
    koopa::defunct koopa::is_macos
}

koopa::is_matching_fixed() {  #{{{1
    # """
    # @note Updated 2020-04-29.
    # """
    koopa::defunct koopa::str_match
}

koopa::is_matching_regex() {  #{{{1
    # """
    # @note Updated 2020-04-29.
    # """
    koopa::defunct koopa::str_match_regex
}

koopa::prefix_mkdir() { # {{{1
    # """
    # @note Updated 2020-02-19.
    # """
    koopa::defunct koopa::mkdir
}

koopa::quiet_cd() { # {{{1
    # """
    # @note Updated 2020-02-16.
    # """
    koopa::defunct koopa::cd
}

koopa::update_profile() { # {{{1
    # """
    # @note Updated 2020-02-15.
    # """
    koopa::defunct koopa::update_etc_profile_d
}

koopa::update_shells() { # {{{1
    # """
    # @note Updated 2020-02-11.
    # """
    koopa::defunct koopa::enable_shell
}
