#!/usr/bin/env bash

koopa_check_shared_object() {
    # """
    # Check shared object file.
    # @note Updated 2022-08-02.
    #
    # @examples
    # > koopa_check_shared_object \
    # >     --name='libR' \
    # >     --prefix='/opt/koopa/opt/r/lib/R/lib'
    # """
    local app dict tool_args
    koopa_assert_has_args "$#"
    declare -A app
    declare -A dict=(
        [name]=''
        [prefix]=''
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
            '--prefix='*)
                dict[prefix]="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict[prefix]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--name' "${dict[name]}" \
        '--prefix' "${dict[prefix]}"
    tool_args=()
    if koopa_is_linux
    then
        app[tool]="$(koopa_locate_ldd)"
        dict[shared_ext]='so'
    elif koopa_is_macos
    then
        app[tool]="$(koopa_macos_locate_otool)"
        dict[shared_ext]='dylib'
        tool_args+=('-L')
    fi
    [[ -x "${app[tool]}" ]] || return 1
    dict[file]="${dict[prefix]}/${dict[name]}.${dict[shared_ext]}"
    koopa_assert_is_file "${dict[file]}"
    tool_args+=("${dict[file]}")
    "${app[tool]}" "${tool_args[@]}"
    return 0
}
