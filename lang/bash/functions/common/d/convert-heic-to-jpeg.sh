#!/usr/bin/env bash

koopa_convert_heic_to_jpeg() {
    # """
    # Convert HEIC images (from iPhone) to JPEG.
    # @note Updated 2023-12-17.
    # """
    local -A app
    local prefix
    koopa_assert_has_args "$#"
    app['magick']="$(koopa_locate_magick)"
    koopa_assert_is_executable "${app[@]}"
    koopa_assert_is_dir "$@"
    for prefix in "$@"
    do
        local -a heic_files
        readarray -t heic_files <<< "$( \
            koopa_find \
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
