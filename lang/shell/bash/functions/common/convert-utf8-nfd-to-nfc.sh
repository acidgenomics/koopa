#!/usr/bin/env bash

koopa_convert_utf8_nfd_to_nfc() {
    # """
    # Convert UTF-8 NFD to NFC.
    # @note Updated 2021-11-04.
    # """
    local app
    koopa_assert_has_args "$#"
    declare -A app=(
        [convmv]="$(koopa_locate_convmv)"
    )
    koopa_assert_is_file "$@"
    "${app[convmv]}" \
        -r \
        -f 'utf8' \
        -t 'utf8' \
        --nfc \
        --notest \
        "$@"
    return 0
}
