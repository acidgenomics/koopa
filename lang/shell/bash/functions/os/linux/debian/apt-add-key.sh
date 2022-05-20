#!/usr/bin/env bash

koopa_debian_apt_add_key() {
    # """
    # Add a GPG key (and/or keyring) for apt.
    # @note Updated 2021-11-09.
    #
    # @section Hardening against insecure URL failure:
    #
    # Using '--insecure' flag here to handle some servers
    # (e.g. download.opensuse.org) that can fail otherwise.
    #
    # @section Regarding apt-key deprecation:
    #
    # Although adding keys directly to '/etc/apt/trusted.gpg.d/' is suggested by
    # 'apt-key' deprecation message, as per Debian Wiki, GPG keys for third
    # party repositories should be added to '/usr/share/keyrings', and
    # referenced with the 'signed-by' option in the '/etc/apt/sources.list.d'
    # entry.
    #
    # @section Alternative approach using tee:
    #
    # > koopa_parse_url --insecure "${dict[url]}" \
    # >     | "${app[gpg]}" --dearmor \
    # >     | "${app[sudo]}" "${app[tee]}" "${dict[file]}" \
    # >         >/dev/null 2>&1 \
    # >     || true
    #
    # @seealso
    # - https://github.com/docker/docker.github.io/issues/11625
    # - https://github.com/docker/docker.github.io/issues/
    #     11625#issuecomment-751388087
    # """
    local app dict
    koopa_assert_has_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [gpg]="$(koopa_locate_gpg)"
        [sudo]="$(koopa_locate_sudo)"
    )
    declare -A dict=(
        [name]=''
        [name_fancy]=''
        [prefix]="$(koopa_debian_apt_key_prefix)"
        [url]=''
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--name='*)
                dict[name]="${1#*=}"
                shift 1
                ;;
            '--name')
                dict[name]="${2:?}"
                shift 2
                ;;
            '--name-fancy='*)
                dict[name_fancy]="${1#*=}"
                shift 1
                ;;
            '--name-fancy')
                dict[name_fancy]="${2:?}"
                shift 2
                ;;
            '--prefix='*)
                dict[prefix]="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict[prefix]="${2:?}"
                shift 2
                ;;
            '--url='*)
                dict[url]="${1#*=}"
                shift 1
                ;;
            '--url')
                dict[url]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_dir "${dict[prefix]}"
    dict[file]="${dict[prefix]}/koopa-${dict[name]}.gpg"
    [[ -f "${dict[file]}" ]] && return 0
    koopa_alert "Adding ${dict[name_fancy]} key at '${dict[file]}'."
    koopa_parse_url --insecure "${dict[url]}" \
        | "${app[sudo]}" "${app[gpg]}" \
            --dearmor \
            --output "${dict[file]}" \
            >/dev/null 2>&1 \
        || true
    koopa_assert_is_file "${dict[file]}"
    return 0
}
