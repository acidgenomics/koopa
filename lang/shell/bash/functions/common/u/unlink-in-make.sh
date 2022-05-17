#!/usr/bin/env bash

koopa_unlink_in_make() {
    # """
    # Unlink a program symlinked in koopa 'make/' directory.
    # @note Updated 2022-04-07.
    #
    # @examples
    # > koopa_unlink_in_make '/opt/koopa/app/autoconf'
    #
    # Unlink all koopa apps with:
    # > koopa_unlink_in_make '/opt/koopa/app'
    # """
    local app_prefix dict files
    koopa_assert_has_args "$#"
    declare -A dict=(
        [app_prefix]=''
        [make_prefix]="$(koopa_make_prefix)"
    )
    koopa_assert_is_dir "${dict[make_prefix]}"
    for app_prefix in "$@"
    do
        dict[app_prefix]="$app_prefix"
        koopa_assert_is_dir "${dict[app_prefix]}"
        dict[app_prefix]="$(koopa_realpath "${dict[app_prefix]}")"
        readarray -t files <<< "$( \
            koopa_find_symlinks \
                --source-prefix="${dict[app_prefix]}" \
                --target-prefix="${dict[make_prefix]}" \
                --verbose \
        )"
        if koopa_is_array_empty "${files[@]:-}"
        then
            koopa_stop "No files from '${dict[app_prefix]}' detected."
        fi
        koopa_alert "$(koopa_ngettext \
            --prefix='Unlinking ' \
            --num="${#files[@]}" \
            --msg1='file' \
            --msg2='files' \
            --suffix=" from '${dict[app_prefix]}' in '${dict[make_prefix]}'." \
        )"
        for file in "${files[@]}"
        do
            koopa_rm "$file"
        done
    done
    return 0
}
