#!/usr/bin/env bash

koopa::generate_ssh_key() { # {{{1
    # """
    # Generate SSH key.
    # @note Updated 2021-04-26.
    #
    # This script is called inside 'configure-vm', so don't use assert here.
    #
    # With ssh-keygen use the '-o' option for the new RFC4716 key format and the
    # use of a modern key derivation function powered by bcrypt. Use the
    # '-a <num>' option for <num> amount of rounds.
    #
    # Actually, it appears that when creating a Ed25519, key the '-o' option
    # is implied.
    #
    # @seealso
    # - https://blog.g3rt.nl/upgrade-your-ssh-keys.html
    # """
    local comment file flags hostname key_name user
    koopa::assert_is_installed 'ssh-keygen'
    user="$(koopa::user)"
    hostname="$(koopa::hostname)"
    comment="${user}@${hostname}"
    key_name='id_ed25519'
    while (("$#"))
    do
        case "$1" in
            '--comment='*)
                comment="${1#*=}"
                shift 1
                ;;
            '--key-name='*)
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
    flags=(
        '-C' "$comment"
        '-N' ''
        '-f' "$file"
        '-q'
    )
    if koopa::str_match_fixed "$file" '_rsa'
    then
        # RSA 4096.
        flags+=(
            '-b' 4096
            '-t' 'rsa'
        )
    else
        # Ed25519 (now recommended).
        flags+=(
            '-a' 100
            '-o'
            '-t' 'ed25519'
        )
    fi
    koopa::dl 'Flags' "${flags[*]}"
    ssh-keygen "${flags[@]}"
    koopa::alert_success "Generated SSH key at '${file}'."
    return 0
}

koopa::ssh_key_info() { # {{{1
    # """
    # Get SSH key information.
    # @note Updated 2021-06-04.
    # @seealso
    # - https://blog.g3rt.nl/upgrade-your-ssh-keys.html
    # """
    for keyfile in "${HOME:?}/.ssh/id_"*
    do
        ssh-keygen -l -f "${keyfile}"
    done | uniq
    return 0
}
