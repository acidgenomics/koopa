#!/usr/bin/env bash

koopa::generate_ssh_key() { # {{{1
    # """
    # Generate SSH key.
    # @note Updated 2021-03-18.
    # This script is called inside 'configure-vm', so don't use assert here.
    # """
    local comment file hostname key_name user
    koopa::is_installed ssh-keygen || return 0
    user="$(koopa::user)"
    hostname="$(koopa::hostname)"
    comment="${user}@${hostname}"
    key_name='id_rsa'
    while (("$#"))
    do
        case "$1" in
            --comment=*)
                comment="${1#*=}"
                shift 1
                ;;
            --key-name=*)
                key_name="${1#*=}"
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    file="${HOME:?}/.ssh/${key_name}"
    [[ -f "$file" ]] && return 0
    ssh-keygen \
        -C "$comment" \
        -N "" \
        -b 4096 \
        -f "$file" \
        -q \
        -t rsa
    koopa::success "Generated SSH key at '${file}'."
    return 0
}
