#!/usr/bin/env bash

_koopa_convert_heic_to_jpeg() {
    # """
    # Convert HEIC images (from iPhone) to JPEG.
    # @note Updated 2023-12-17.
    # """
    local -A app
    local prefix
    _koopa_assert_has_args "$#"
    app['magick']="$(_koopa_locate_magick)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_assert_is_dir "$@"
    for prefix in "$@"
    do
        local -a heic_files
        readarray -t heic_files <<< "$( \
            _koopa_find \
                --pattern='*.heic' \
                --prefix="$prefix" \
                --sort \
                --type='f' \
        )"
        "${app['magick']}" mogrify \
            -format 'jpg' \
            -monitor \
            "${heic_files[@]}"
    done
    return 0
}
