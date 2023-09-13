#!/bin/sh

# FIXME How to skip if the user has a passkey set?

_koopa_activate_ssh_key() {
    # """
    # Import an SSH key automatically.
    # @note Updated 2023-09-13.
    #
    # NOTE: SCP will fail unless this is interactive only.
    # ssh-agent will prompt for password if there's one set.
    #
    # To change SSH key passphrase:
    # > ssh-keygen -p
    #
    # List currently loaded keys:
    # > ssh-add -L
    # """
    _koopa_is_linux || return 0
    __kvar_key="${1:-}"
    if [ -z "$__kvar_key" ] && [ -n "${SSH_KEY:-}" ]
    then
        __kvar_key="${SSH_KEY:?}"
    else
        __kvar_key="${HOME:?}/.ssh/id_rsa"
    fi
    if [ ! -r "$__kvar_key" ]
    then
        unset -v __kvar_key
        return 0
    fi
    _koopa_is_installed 'ssh-add' 'ssh-agent' || return 1
    __kvar_nounset="$(_koopa_boolean_nounset)"
    [ "$__kvar_nounset" -eq 1 ] && set +o nounset
    eval "$(ssh-agent -s)" >/dev/null 2>&1
    [ "$__kvar_nounset" -eq 1 ] && set -o nounset
    ssh-add "$__kvar_key" >/dev/null 2>&1
    unset -v \
        __kvar_key \
        __kvar_nounset
    return 0
}
