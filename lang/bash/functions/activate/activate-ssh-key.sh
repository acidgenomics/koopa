#!/usr/bin/env bash

_koopa_activate_ssh_key() {
    local key nounset
    _koopa_is_linux || return 0
    key="${1:-}"
    if [[ -z "$key" ]] && [[ -n "${SSH_KEY:-}" ]]
    then
        key="${SSH_KEY:?}"
    else
        key="${HOME:?}/.ssh/id_rsa"
    fi
    if [[ ! -r "$key" ]]
    then
        return 0
    fi
    _koopa_is_installed 'ssh-add' 'ssh-agent' || return 1
    nounset="$(_koopa_boolean_nounset)"
    [[ "$nounset" -eq 1 ]] && set +o nounset
    eval "$(ssh-agent -s)" >/dev/null 2>&1
    [[ "$nounset" -eq 1 ]] && set -o nounset
    ssh-add "$key" >/dev/null 2>&1
    return 0
}
