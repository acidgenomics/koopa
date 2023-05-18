#!/usr/bin/env bash

koopa_tar_multiple_dirs() {
    # """
    # Compress (tar) multiple directories in a single call.
    # @note Updated 2023-04-05.
    # """
    local -A app dict
    local -a dirs pos
    local dir
    koopa_assert_has_args "$#"
    app['tar']="$(koopa_locate_tar --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['delete']=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Flags ------------------------------------------------------------
            '--delete')
                dict['delete']=1
                shift 1
                ;;
            '--no-delete' | \
            '--keep')
                dict['delete']=0
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
    koopa_assert_is_dir "$@"
    readarray -t dirs <<< "$(koopa_realpath "$@")"
    (
        for dir in "${dirs[@]}"
        do
            local bn
            bn="$(koopa_basename "$dir")"
            koopa_alert "Compressing '${dir}'."
            koopa_cd "$(koopa_dirname "$dir")"
            "${app['tar']}" -czf "${bn}.tar.gz" "${bn}/"
            [[ "${dict['delete']}" -eq 1 ]] && koopa_rm "$dir"
        done
    )
    return 0
}
