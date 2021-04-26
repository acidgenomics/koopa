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
    koopa::alert_success "Generated SSH key at '${file}'."
    return 0
}

koopa::ssh_key_info() { # {{{1
    # """
    # Get SSH key information.
    # @note Updated 2021-04-26.
    # @seealso
    # - https://blog.g3rt.nl/upgrade-your-ssh-keys.html
    # """
    for keyfile in ~/.ssh/id_*
    do
        ssh-keygen -l -f "${keyfile}"
    done | uniq
    return 0
}
