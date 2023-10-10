#!/usr/bin/env bash

koopa_r_gfortran_libs() {
    # """
    # Define FLIBS for our R gfortran configuration.
    # @note Updated 2023-10-10.
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
        dict['gfortran']="$(koopa_app_prefix 'gcc')"

    elif koopa_is_macos
    then
        case "${dict['arch']}" in
            'arm64')
                dict['arch']='aarch64'
                ;;
        esac
        dict['gfortran']='/opt/gfortran'
        koopa_assert_is_dir "${dict['gfortran']}"
        # FIXME We need to search for 'libgfortran.dylib' and get the
        # parent directory.
        readarray -t libs <<< "$( \
            koopa_find \
                --max-depth=2 \
                --min-depth=2 \
                --pattern="${dict['arch']}*" \
                --prefix="${dict['gfortran']}/lib/gcc" \
                --type='d' \
        )"
    fi
    koopa_assert_is_dir "${dict['gfortran']}"
    readarray -t libs <<< "$( \
        koopa_find \
            --pattern='*.a' \
            --prefix="${dict['gfortran']}" \
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
        libs+=("${dict['gfortran']}/lib")
    fi
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
