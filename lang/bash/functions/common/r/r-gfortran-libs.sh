#!/usr/bin/env bash

# FIXME Use system gcc here on Linux.
# FIXME Rework to look for libgfortran instead.
# FIXME Can just return the flags on Linux.

koopa_r_gfortran_libs() {
    # """
    # Define FLIBS for our R gfortran configuration.
    # @note Updated 2023-10-11.
    #
    # Locate gfortran library paths (from GCC). This will cover 'lib' and
    # 'lib64' subdirs. See also 'gcc --print-search-dirs'.
    # """
    local -A app dict
    local -a flibs libs
    local i
    koopa_assert_has_no_args "$#"
    app['dirname']="$(koopa_locate_dirname --allow-system)"
    app['sort']="$(koopa_locate_sort --allow-system)"
    app['xargs']="$(koopa_locate_xargs --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['arch']="$(koopa_arch)"
    if koopa_is_linux
    then
        dict['lib_prefix']='/usr/lib'

    elif koopa_is_macos
    then
        case "${dict['arch']}" in
            'arm64')
                dict['arch']='aarch64'
                ;;
        esac
        dict['lib_prefix']='/opt/gfortran/lib'
    fi
    koopa_assert_is_dir "${dict['lib_prefix']}"
    # FIXME Need to look for libgfortran specifically here.
    readarray -t libs <<< "$( \
        koopa_find \
            --pattern='*.a' \
            --prefix="${dict['lib_prefix']}" \
            --type='f' \
        | "${app['xargs']}" -I '{}' "${app['dirname']}" '{}' \
        | "${app['sort']}" --unique \
    )"
    koopa_assert_is_array_non_empty "${libs[@]:-}"
    if koopa_is_macos
    then
        # Need to exclude other architectures in the universal build.
        local -a libs2
        local lib
        for lib in "${libs[@]}"
        do
            case "$lib" in
                */"${dict['arch']}-"*)
                    libs2+=("$lib")
                    ;;
            esac
        done
        koopa_assert_is_array_non_empty "${libs2[@]:-}"
        libs=("${libs2[@]}")
    fi
    libs+=("${dict['lib_prefix']}")
    for i in "${!libs[@]}"
    do
        flibs+=("-L${libs[$i]}")
    done
    flibs+=('-lgfortran')
    if koopa_is_linux
    then
        flibs+=('-lm')
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
