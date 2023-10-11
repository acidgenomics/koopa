#!/usr/bin/env bash

koopa_r_gfortran_libs() {
    # """
    # Define FLIBS for our R gfortran configuration.
    # @note Updated 2023-10-11.
    #
    # Locate gfortran library paths (from GCC). This will cover 'lib' and
    # 'lib64' subdirs. See also 'gcc --print-search-dirs'.
    # """
    local -A app dict
    local -a flibs libs libs2
    local lib
    koopa_assert_has_no_args "$#"
    dict['arch']="$(koopa_arch)"
    if koopa_is_linux
    then
        app['gfortran']="$(koopa_locate_gfortran --only-system)"
        koopa_assert_is_executable "${app[@]}"
    elif koopa_is_macos
    then
        app['dirname']="$(koopa_locate_dirname --allow-system)"
        app['sort']="$(koopa_locate_sort --allow-system)"
        app['xargs']="$(koopa_locate_xargs --allow-system)"
        koopa_assert_is_executable "${app[@]}"
        case "${dict['arch']}" in
            'arm64')
                dict['arch']='aarch64'
                ;;
        esac
        dict['lib_prefix']='/opt/gfortran/lib'
        koopa_assert_is_dir "${dict['lib_prefix']}"
        readarray -t libs <<< "$( \
            koopa_find \
                --pattern='libgfortran.a' \
                --prefix="${dict['lib_prefix']}" \
                --type='f' \
            | "${app['xargs']}" -I '{}' "${app['dirname']}" '{}' \
            | "${app['sort']}" --unique \
        )"
        koopa_assert_is_array_non_empty "${libs[@]:-}"
        # Need to exclude other architectures in the universal build.
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
        libs+=("${dict['lib_prefix']}")
        for lib in "${libs[@]}"
        do
            flibs+=("-L${lib}")
        done
    fi
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
