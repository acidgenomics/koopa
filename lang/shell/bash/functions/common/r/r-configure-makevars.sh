#!/usr/bin/env bash

koopa_r_configure_makevars() {
    # """
    # Configure 'Makevars.site' file with compiler settings.
    # @note Updated 2022-07-28.
    # """
    local app cppflags dict flibs i ldflags libs
    koopa_assert_has_args_eq "$#" 1
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
    koopa_is_koopa_app "${app[r]}" && return 0
    declare -A dict=(
        [arch]="$(koopa_arch)"
        [opt_prefix]="$(koopa_opt_prefix)"
        [r_prefix]="$(koopa_r_prefix "${app[r]}")"
    )
    dict[file]="${dict[r_prefix]}/etc/Makevars.site"
    koopa_alert "Configuring '${dict[file]}'."
    if koopa_is_linux
    then
        dict[freetype]="$(koopa_realpath "${dict[opt_prefix]}/freetype")"
        read -r -d '' "dict[string]" << END || true
CPPFLAGS += -I${dict[freetype]}/include/freetype2
END
    elif koopa_is_macos
    then
        dict[gcc]="$(koopa_realpath "${dict[opt_prefix]}/gcc")"
        # gettext is needed to resolve clang '-lintl' warning.
        dict[gettext]="$(koopa_realpath "${dict[opt_prefix]}/gettext")"
        app[fc]="${dict[gcc]}/bin/gfortran"
        # This will cover 'lib' and 'lib64' subdirs.
        # See also 'gcc --print-search-dirs'.
        readarray -t libs <<< "$( \
            koopa_find \
                --prefix="${dict[gcc]}" \
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
        # quadmath not yet supported for aarch64.
        # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=96016
        case "${dict[arch]}" in
            'x86_64')
                flibs+=('-lquadmath')
                ;;
        esac
        # Consider also including '-lemutls_w' here, which is recommended by
        # default macOS build config.
        flibs+=('-lm')
        dict[flibs]="${flibs[*]}"
        cppflags=('-Xclang' '-fopenmp')
        dict[cppflags]="${cppflags[*]}"
        ldflags=(
            "-I${dict[gettext]}/include"
            "-L${dict[gettext]}/lib"
            '-lomp'
        )
        dict[ldflags]="${ldflags[*]}"
        read -r -d '' "dict[string]" << END || true
CPPFLAGS += ${dict[cppflags]}
FC = ${app[fc]}
FLIBS = ${dict[flibs]}
LDFLAGS += ${dict[ldflags]}
END
    fi
    # This should only apply to R CRAN binary, not source install.
    koopa_sudo_write_string \
        --file="${dict[file]}" \
        --string="${dict[string]}"
    return 0
}
