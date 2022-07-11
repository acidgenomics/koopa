#!/usr/bin/env bash

koopa_r_makevars() {
    # """
    # Generate 'Makevars.site' file with compiler settings.
    # @note Updated 2022-07-11.
    # """
    local app dict flibs i libs
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [dirname]="$(koopa_locate_dirname)"
        [r]="${1:?}"
        [sort]="$(koopa_locate_sort)"
        [xargs]="$(koopa_locate_xargs)"
    )
    koopa_assert_is_installed "${app[r]}"
    [[ -x "${app[dirname]}" ]] || return 1
    [[ -x "${app[sort]}" ]] || return 1
    [[ -x "${app[xargs]}" ]] || return 1
    if koopa_is_linux && ! koopa_is_koopa_app "${app[r]}"
    then
        return 0
    fi
    declare -A dict=(
        [opt_prefix]="$(koopa_opt_prefix)"
        [r_prefix]="$(koopa_r_prefix "${app[r]}")"
    )
    dict[file]="${dict[r_prefix]}/etc/Makevars.site"
    koopa_alert "Updating 'Makevars' at '${dict[file]}'."
    dict[gcc_prefix]="$(koopa_realpath "${dict[opt_prefix]}/gcc")"
    app[fc]="${dict[gcc_prefix]}/bin/gfortran"
    readarray -t libs <<< "$( \
        koopa_find \
            --prefix="${dict[gcc_prefix]}/lib" \
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
    flibs+=('-lgfortran' '-lquadmath' '-lm')
    dict[flibs]="${flibs[*]}"
    read -r -d '' "dict[string]" << END || true
FC = ${app[fc]}
FLIBS = ${dict[flibs]}
END
    if koopa_is_koopa_app "${app[r]}"
    then
        koopa_write_string \
            --file="${dict[file]}" \
            --string="${dict[string]}"
    elif koopa_is_macos
    then
        # This applies to R CRAN binary.
        koopa_sudo_write_string \
            --file="${dict[file]}" \
            --string="${dict[string]}"
    fi
    return 0
}
