#!/usr/bin/env bash

# FIXME Our find step on macOS inconsistently returns trailing slash.

koopa_r_gfortran_libs() {
    # """
    # Define FLIBS for our R gfortran configuration.
    # @note Updated 2023-10-09.
    #
    # Locate gfortran library paths (from GCC). This will cover 'lib' and
    # 'lib64' subdirs. See also 'gcc --print-search-dirs'.
    # """
    local -A app dict
    local -a flibs libs
    local i
    dict['arch']="$(koopa_arch)"
    if koopa_is_linux
    then
        app['dirname']="$(koopa_locate_dirname --allow-system)"
        app['sort']="$(koopa_locate_sort --allow-system)"
        app['xargs']="$(koopa_locate_xargs --allow-system)"
        koopa_assert_is_executable "${app[@]}"
        dict['gcc']="$(koopa_app_prefix 'gcc')"
        koopa_assert_is_dir "${dict['gcc']}"
        readarray -t libs <<< "$( \
            koopa_find \
                --pattern='*.a' \
                --prefix="${dict['gcc']}" \
                --type 'f' \
            | "${app['xargs']}" -I '{}' "${app['dirname']}" '{}' \
            | "${app['sort']}" --unique \
        )"
    elif koopa_is_macos
    then
        case "${dict['arch']}" in
            'arm64')
                dict['arch']='aarch64'
                ;;
        esac
        dict['gfortran']='/opt/gfortran'
        koopa_assert_is_dir "${dict['gfortran']}"
        readarray -t libs <<< "$( \
            koopa_find \
                --max-depth=1 \
                --min-depth=1 \
                --pattern="${dict['arch']}*" \
                --prefix="${dict['gfortran']}/lib/gcc" \
                --type='d' \
        )"
        libs+=("${dict['gfortran']}/lib")
    fi
    koopa_assert_is_array_non_empty "${libs[@]:-}"
    for i in "${!libs[@]}"
    do
        flibs+=("-L${libs[$i]}")
    done
    flibs+=('-lgfortran')
    if koopa_is_linux
    then
        flibs+=('-lm')
    elif koopa_is_macos
    then
        flibs+=('-lemutls_w')
    fi
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
