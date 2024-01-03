#!/usr/bin/env bash

koopa_ssh_generate_key() {
    # """
    # Generate SSH key.
    # @note Updated 2024-01-03.
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
    local -a pos
    local key_name
    koopa_assert_has_args "$#"
    app['ssh_keygen']="$(koopa_locate_ssh_keygen --allow-system --realpath)"
    koopa_assert_is_executable "${app[@]}"
    dict['hostname']="$(koopa_hostname)"
    dict['prefix']="${HOME:?}/.ssh"
    dict['user']="$(koopa_user_name)"
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    dict['prefix']="$(koopa_init_dir "${dict['prefix']}")"
    for key_name in "$@"
    do
        local -A dict2
        local -a ssh_args
        dict2['key_name']="$key_name"
        dict2['file']="${dict['prefix']}/${dict2['key_name']}"
        if [[ -f "${dict2['file']}" ]]
        then
            koopa_alert_note "SSH key exists at '${dict2['file']}'."
            return 0
        fi
        koopa_alert "Generating SSH key at '${dict2['file']}'."
        ssh_args+=(
            '-C' "${dict['user']}@${dict['hostname']}"
            '-N' ''
            '-f' "${dict2['file']}"
            '-q'
        )
        case "${dict2['key_name']}" in
            *'-ed25519' | \
            *'_ed25519')
                # Ed25519.
                ssh_args+=(
                    '-a' 100
                    '-o'
                    '-t' 'ed25519'
                )
                ;;
            *'-rsa' | \
            *'_rsa')
                # RSA 4096.
                ssh_args+=(
                    '-b' 4096
                    '-t' 'rsa'
                )
                ;;
            *)
                koopa_stop "Unsupported key: '${dict2['key_name']}'."
                ;;
        esac
        koopa_dl \
            'ssh-keygen' "${app['ssh_keygen']}" \
            'args' "${ssh_args[*]}"
        "${app['ssh_keygen']}" "${ssh_args[@]}"
        koopa_alert_success "Generated SSH key at '${dict2['file']}'."
    done
    return 0
}
