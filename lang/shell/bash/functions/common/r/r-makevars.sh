#!/usr/bin/env bash

# FIXME Consider making this macOS-specific and rename the function.

koopa_r_makevars() {
    # """
    # Generate 'Makevars.site' file with compiler settings.
    # @note Updated 2022-07-19.
    # """
    local app dict flibs i libs
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [dirname]="$(koopa_locate_dirname)"
        [r]="${1:?}"
        [sort]="$(koopa_locate_sort)"
        [xargs]="$(koopa_locate_xargs)"
    )
    [[ -x "${app[dirname]}" ]] || return 1
    [[ -x "${app[r]}" ]] || return 1
    [[ -x "${app[sort]}" ]] || return 1
    [[ -x "${app[xargs]}" ]] || return 1
    # FIXME Rename the function, based on this line.
    koopa_is_macos || return 0
    ! koopa_is_koopa_app "${app[r]}" || return 0
    declare -A dict=(
        [arch]="$(koopa_arch)"
        [opt_prefix]="$(koopa_opt_prefix)"
        [r_prefix]="$(koopa_r_prefix "${app[r]}")"
    )
    dict[file]="${dict[r_prefix]}/etc/Makevars.site"
    koopa_alert "Updating 'Makevars' at '${dict[file]}'."
    dict[gcc_prefix]="$(koopa_realpath "${dict[opt_prefix]}/gcc")"
    app[fc]="${dict[gcc_prefix]}/bin/gfortran"
    # This will cover 'lib' and 'lib64' subdirs.
    # See also 'gcc --print-search-dirs'.
    readarray -t libs <<< "$( \
        koopa_find \
            --prefix="${dict[gcc_prefix]}" \
            --pattern='*.a' \
            --type 'f' \
        | "${app[xargs]}" -I '{}' "${app[dirname]}" '{}' \
        | "${app[sort]}" --unique \
    )"
    koopa_assert_is_array_non_empty "${libs[@]:-}"
    flibs=()
    for i in "${!libs[@]}"
    do
        flibs+=("-L${libs[i]}")
    done
    flibs+=('-lgfortran')
    # NOTE quadmath not yet supported for aarch64.
    # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=96016
    case "${dict[arch]}" in
        'x86_64')
            flibs+=('-lquadmath')
            ;;
    esac
    # NOTE Consider also including '-lemutls_w' here, which is recommended
    # by default macOS build config.
    flibs+=('-lm')
    dict[flibs]="${flibs[*]}"
    read -r -d '' "dict[string]" << END || true
FC = ${app[fc]}
FLIBS = ${dict[flibs]}
END
    # This applies to R CRAN binary.
    koopa_sudo_write_string \
        --file="${dict[file]}" \
        --string="${dict[string]}"
    return 0
}
