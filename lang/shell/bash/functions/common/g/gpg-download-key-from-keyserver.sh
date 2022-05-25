#!/usr/bin/env bash

koopa_gpg_download_key_from_keyserver() {
    # """
    # Download a GPG key from a keyserver to a local file, without importing.
    # @note Updated 2022-05-20.
    #
    # @seealso
    # - https://superuser.com/a/1643115/589630
    # """
    local app cp dict
    koopa_assert_has_args "$#"
    declare -A app=(
        [gpg]="$(koopa_locate_gpg)"
    )
    [[ -x "${app[gpg]}" ]] || return 1
    declare -A dict=(
        [sudo]=0
        [tmp_dir]="$(koopa_tmp_dir)"
    )
    dict[tmp_file]="${dict[tmp_dir]}/export.gpg"
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--file='*)
                dict[file]="${1#*=}"
                shift 1
                ;;
            '--file')
                dict[file]="${2:?}"
                shift 2
                ;;
            '--key='*)
                dict[key]="${1#*=}"
                shift 1
                ;;
            '--key')
                dict[key]="${2:?}"
                shift 2
                ;;
            '--keyserver='*)
                dict[keyserver]="${1#*=}"
                shift 1
                ;;
            '--keyserver')
                dict[keyserver]="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--sudo')
                dict[sudo]=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    [[ -f "${dict[file]}" ]] && return 0
    koopa_alert "Exporting GPG key '${dict[key]}' at '${dict[file]}'."
    cp=('koopa_cp')
    [[ "${dict[sudo]}" -eq 1 ]] && cp+=('--sudo')
    "${app[gpg]}" \
        --homedir "${dict[tmp_dir]}" \
        --quiet \
        --keyserver "${dict[keyserver]}" \
        --recv-keys "${dict[key]}"
    "${app[gpg]}" \
        --homedir "${dict[tmp_dir]}" \
        --list-public-keys "${dict[key]}"
    "${app[gpg]}" \
        --homedir "${dict[tmp_dir]}" \
        --export \
        --quiet \
        --output "${dict[tmp_file]}" \
        "${dict[key]}"
    koopa_assert_is_file "${dict[tmp_file]}"
    "${cp[@]}" "${dict[tmp_file]}" "${dict[file]}"
    koopa_rm "${dict[tmp_dir]}"
    koopa_assert_is_file "${dict[file]}"
    return 0
}
