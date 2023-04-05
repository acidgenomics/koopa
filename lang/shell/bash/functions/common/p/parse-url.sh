#!/usr/bin/env bash

koopa_parse_url() {
    # """
    # Parse a URL using cURL.
    # @note Updated 2023-04-05.
    #
    # Don't use 'koopa_print' here, since we need to pass binary output
    # in some cases for GPG key configuration.
    #
    # Keep in mind that '--disable' must come first in curl args.
    # """
    local -A app
    local -a curl_args pos
    koopa_assert_has_args "$#"
    app['curl']="$(koopa_locate_curl --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    curl_args=(
        '--disable'
        '--fail'
        '--location'
        '--retry' 5
        '--show-error'
        '--silent'
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Flags ------------------------------------------------------------
            '--insecure' | \
            '--list-only')
                curl_args+=("$1")
                shift 1
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
    koopa_assert_has_args_eq "$#" 1
    curl_args+=("${1:?}")
    "${app['curl']}" "${curl_args[@]}"
    return 0
}
