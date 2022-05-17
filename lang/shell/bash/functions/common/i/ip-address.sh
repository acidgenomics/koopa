#!/usr/bin/env bash

koopa_ip_address() {
    # """
    # IP address.
    # @note Updated 2022-02-09.
    # """
    local dict
    declare -A dict=(
        [type]='public'
    )
    while (("$#"))
    do
        case "$1" in
            '--local')
                dict[type]='local'
                shift 1
                ;;
            '--public')
                dict[type]='public'
                shift 1
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    case "${dict[type]}" in
        'local')
            koopa_local_ip_address
            ;;
        'public')
            koopa_public_ip_address
            ;;
    esac
    return 0
}
