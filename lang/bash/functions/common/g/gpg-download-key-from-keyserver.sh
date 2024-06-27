#!/usr/bin/env bash

koopa_gpg_download_key_from_keyserver() {
    # """
    # Download a GPG key from a keyserver to a local file, without importing.
    # @note Updated 2024-06-27.
    #
    # @seealso
    # - https://superuser.com/a/1643115/589630
    # """
    local -A app dict
    local -a cp
    koopa_assert_has_args "$#"
    app['gpg']="$(koopa_locate_gpg --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['sudo']=0
    dict['tmp_dir']="$(koopa_tmp_dir)"
    dict['tmp_file']="${dict['tmp_dir']}/export.gpg"
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--file='*)
                dict['file']="${1#*=}"
                shift 1
                ;;
            '--file')
                dict['file']="${2:?}"
                shift 2
                ;;
            '--key='*)
                dict['key']="${1#*=}"
                shift 1
                ;;
            '--key')
                dict['key']="${2:?}"
                shift 2
                ;;
            '--keyserver='*)
                dict['keyserver']="${1#*=}"
                shift 1
                ;;
            '--keyserver')
                dict['keyserver']="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--sudo')
                dict['sudo']=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    [[ -f "${dict['file']}" ]] && return 0
    koopa_alert "Exporting GPG key '${dict['key']}' at '${dict['file']}'."
    cp=('koopa_cp')
    [[ "${dict['sudo']}" -eq 1 ]] && cp+=('--sudo')
    "${app['gpg']}" \
        --homedir "${dict['tmp_dir']}" \
        --keyserver "hkp://${dict['keyserver']}:80" \
        --keyserver-options "http-proxy=${http_proxy:-}" \
        --quiet \
        --recv-keys "${dict['key']}"
    "${app['gpg']}" \
        --homedir "${dict['tmp_dir']}" \
        --list-public-keys "${dict['key']}"
    "${app['gpg']}" \
        --export \
        --homedir "${dict['tmp_dir']}" \
        --output "${dict['tmp_file']}" \
        --quiet \
        "${dict['key']}"
    koopa_assert_is_file "${dict['tmp_file']}"
    "${cp[@]}" "${dict['tmp_file']}" "${dict['file']}"
    koopa_rm "${dict['tmp_dir']}"
    koopa_assert_is_file "${dict['file']}"
    return 0
}
