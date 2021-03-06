#!/usr/bin/env bash

koopa::generate_ssh_key() { # {{{1
    # """
    # Generate SSH key.
    # @note Updated 2020-07-30.
    # This script is called inside 'configure-vm', so don't use assert here.
    # """
    local comment file key_name
    koopa::is_installed ssh-keygen || return 0
    comment="${USER}@${HOSTNAME}"
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
    file="${HOME}/.ssh/${key_name}"
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
