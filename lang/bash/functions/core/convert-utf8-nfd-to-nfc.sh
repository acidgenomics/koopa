#!/usr/bin/env bash

_koopa_convert_utf8_nfd_to_nfc() {
    # """
    # Convert UTF-8 NFD to NFC.
    # @note Updated 2021-11-04.
    # """
    local -A app
    _koopa_assert_has_args "$#"
    app['convmv']="$(_koopa_locate_convmv)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_assert_is_file "$@"
    "${app['convmv']}" \
        -r \
        -f 'utf8' \
        -t 'utf8' \
        --nfc \
        --notest \
        "$@"
    return 0
}
