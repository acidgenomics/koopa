#!/usr/bin/env bash

koopa_ssh_generate_key() {
    # """
    # Generate SSH key.
    # @note Updated 2023-04-05.
    #
    # This script is called inside our Linux VM configuration function, so
    # don't use assert here.
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
    local -A app dict
    local -a ssh_args
    app['ssh_keygen']="$(koopa_locate_ssh_keygen --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['hostname']="$(koopa_hostname)"
    dict['key_name']='id_rsa' # or 'id_ed25519'.
    dict['prefix']="${HOME:?}/.ssh"
    dict['user']="$(koopa_user_name)"
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--key-name='*)
                dict['key_name']="${1#*=}"
                shift 1
                ;;
            '--key-name')
                dict['key_name']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    file="${dict['prefix']}/${dict['key_name']}"
    if [[ -f "${dict['file']}" ]]
    then
        koopa_alert_note "SSH key exists at '${dict['file']}'."
        return 0
    fi
    koopa_alert "Generating SSH key at '${dict['file']}'."
    ssh_args=(
        '-C' "${dict['user']}@${dict['hostname']}"
        '-N' ''
        '-f' "${dict['file']}"
        '-q'
    )
    case "${dict['key_name']}" in
        *'_ed25519')
            # Ed25519.
            ssh_args+=(
                '-a' 100
                '-o'
                '-t' 'ed25519'
            )
            ;;
        *'_rsa')
            # RSA 4096.
            ssh_args+=(
                '-b' 4096
                '-t' 'rsa'
            )
            ;;
        *)
            koopa_stop "Unsupported key: '${dict['key_name']}'."
            ;;
    esac
    koopa_dl \
        'ssh-keygen' "${app['ssh_keygen']}" \
        'args' "${ssh_args[*]}"
    "${app['ssh_keygen']}" "${ssh_args[@]}"
    koopa_alert_success "Generated SSH key at '${dict['file']}'."
    return 0
}
