#!/usr/bin/env bash

koopa_gfortran_libs() {
    # """
    # Define FLIBS for our gfortran configuration.
    # @note Updated 2022-08-29.
    #
    # Locate gfortran library paths (from GCC). This will cover 'lib' and
    # 'lib64' subdirs. See also 'gcc --print-search-dirs'.
    # """
    local app dict flibs gcc_libs i
    declare -A app=(
        ['dirname']="$(koopa_locate_dirname)"
        ['sort']="$(koopa_locate_sort)"
        ['xargs']="$(koopa_locate_xargs)"
    )
    [[ -x "${app['dirname']}" ]] || return 1
    [[ -x "${app['sort']}" ]] || return 1
    [[ -x "${app['xargs']}" ]] || return 1
    declare -A dict=(
        ['arch']="$(koopa_arch)"
        ['gcc']="$(koopa_app_prefix 'gcc')"
    )
    koopa_assert_is_dir "${dict['gcc']}"
    readarray -t gcc_libs <<< "$( \
        koopa_find \
            --prefix="${dict['gcc']}" \
            --pattern='*.a' \
            --type 'f' \
        | "${app['xargs']}" -I '{}' "${app['dirname']}" '{}' \
        | "${app['sort']}" --unique \
    )"
    koopa_assert_is_array_non_empty "${gcc_libs[@]:-}"
    for i in "${!gcc_libs[@]}"
    do
        flibs+=("-L${gcc_libs[$i]}")
    done
    # Consider also including '-lemutls_w' here, which is recommended by
    # default macOS build config.
    flibs+=('-lgfortran' '-lm')
    # quadmath is not yet supported for aarch64.
    # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=96016
    case "${dict['arch']}" in
        'x86_64')
            flibs+=('-lquadmath')
            ;;
    esac
    koopa_print "${flibs[*]}"
    return 0
}
