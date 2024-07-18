#!/bin/sh

_koopa_activate_profile_files() {
    # """
    # Source additional profile files.
    # @note Updated 2024-07-18.
    # """
    if [ -r "${HOME:?}/.profile-personal" ]
    then
        # shellcheck source=/dev/null
        . "${HOME:?}/.profile-personal"
    fi
    if [ -r "${HOME:?}/.profile-work" ]
    then
        # shellcheck source=/dev/null
        . "${HOME:?}/.profile-work"
    fi
    if [ -r "${HOME:?}/.profile-private" ]
    then
        # shellcheck source=/dev/null
        . "${HOME:?}/.profile-private"
    fi
    if [ -r "${HOME:?}/.secrets" ]
    then
        # shellcheck source=/dev/null
        . "${HOME:?}/.secrets"
    fi
    if [ -r "${HOME:?}/.secrets-personal" ]
    then
        # shellcheck source=/dev/null
        . "${HOME:?}/.secrets-personal"
    fi
    if [ -r "${HOME:?}/.secrets-work" ]
    then
        # shellcheck source=/dev/null
        . "${HOME:?}/.secrets-work"
    fi
    if [ -r "${HOME:?}/.secrets-private" ]
    then
        # shellcheck source=/dev/null
        . "${HOME:?}/.secrets-private"
    fi
    return 0
}
